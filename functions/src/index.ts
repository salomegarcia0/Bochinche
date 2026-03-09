import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { onSchedule } from "firebase-functions/v2/scheduler";

admin.initializeApp();

export const sendPushNotification = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const notifData = snapshot.data();
    const userId = notifData.userId;
    const title = notifData.titulo || "¡Nuevo Bochinche!";
    const body = notifData.mensaje || "Tienes una nueva actualización.";
    const eventId = notifData.eventId ? String(notifData.eventId) : "";

    if (!userId) {
      console.log("No se encontró userId en la notificación.");
      return;
    }

    try {
      // 1. Buscamos el token del usuario en su documento de perfil
      const userDoc = await admin.firestore().collection("users").doc(userId).get();
      const fcmToken = userDoc.data()?.fcmToken;

      if (!fcmToken) {
        console.log(`El usuario ${userId} no tiene un FCM Token registrado.`);
        return;
      }

      // 2. Construimos el mensaje con el campo 'data' para que el clic funcione
      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: {
          eventId: eventId, 
        },
        token: fcmToken,
      };

      // 3. Enviamos el mensaje a través de Firebase Cloud Messaging
      await admin.messaging().send(message);
      console.log(`✅ Notificación enviada con éxito al usuario ${userId} para el evento ${eventId}`);

    } catch (error) {
      console.error("❌ Error enviando la notificación push:", error);
    }
  }
);

export const checkUpcomingEvents = onSchedule("every 1 hours", async (event) => {
    const db = admin.firestore();
    const now = new Date();
    
    try {
        // 1. Buscamos TODOS los tickets de todos los usuarios usando un "Collection Group"
        // Esto es mucho más eficiente que buscar usuario por usuario
        const ticketsSnapshot = await db.collectionGroup("tickets").get();

        if (ticketsSnapshot.empty) {
            console.log("No hay tickets vendidos en todo el sistema.");
            return;
        }

        const batch = db.batch();
        const eventsCache: { [key: string]: FirebaseFirestore.DocumentData } = {};

        // 2. Revisamos cada ticket
        for (const ticketDoc of ticketsSnapshot.docs) {
            const ticketData = ticketDoc.data();
            const eventId = ticketData.eventId;
            
            // Para saber de quién es este ticket, extraemos el ID del usuario de la ruta del documento
            // Ruta típica: users/{userId}/tickets/{ticketId}
            const userId = ticketDoc.ref.parent.parent?.id; 

            if (!eventId || !userId) continue;

            // 3. Buscamos los datos del evento (usamos un caché para no consultar Firestore 100 veces por el mismo evento)
            if (!eventsCache[eventId]) {
                const eventSnap = await db.collection("events").doc(eventId).get();
                if (eventSnap.exists) {
                    eventsCache[eventId] = eventSnap.data()!;
                } else {
                    continue; 
                }
            }

            const eventData = eventsCache[eventId];
            if (!eventData.startDate) continue;

            // 4. Calculamos el tiempo restante
            const fechaEvento = new Date(eventData.startDate);
            const diffEnMilisegundos = fechaEvento.getTime() - now.getTime();
            const diffEnHoras = diffEnMilisegundos / (1000 * 60 * 60);

            if (diffEnHoras > 0 && diffEnHoras <= 24) {
                // 5. Creamos un ID único para no repetir esta notificación
                const notifId = `${userId}_${eventId}_24h`;
                const notifRef = db.collection("notifications").doc(notifId);

                // Usamos set() con merge: true. Si el documento ya existe (ya le avisamos antes), no hace nada malo.
                batch.set(notifRef, {
                    userId: userId,
                    eventId: eventId,
                    titulo: "¡Tu rumba está súper cerca! ⏱️",
                    mensaje: `Faltan menos de 24 horas para ${eventData.name || "tu evento"}. ¡Prepárate!`,
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                    type: "recordatorio_tiempo",
                    read: false,
                }, { merge: true });
            }
        }

        // 6. Ejecutamos todas las escrituras
        await batch.commit();
        console.log("✅ Revisión de eventos próximos completada.");

    } catch (error) {
        console.error("❌ Error en el cron job de eventos próximos:", error);
    }
});