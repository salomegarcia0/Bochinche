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
      const userDoc = await admin.firestore().collection("users").doc(userId).get();
      const fcmToken = userDoc.data()?.fcmToken;

      if (!fcmToken) {
        console.log(`El usuario ${userId} no tiene un FCM Token registrado.`);
        return;
      }

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

      await admin.messaging().send(message);
      console.log(`✅ Notificación enviada con éxito al usuario ${userId}`);

    } catch (error) {
      console.error("❌ Error enviando la notificación push:", error);
    }
  }
);

export const checkUpcomingEvents = onSchedule("every 1 hours", async (event) => {
    const db = admin.firestore();
    const now = new Date(); // Esta es la hora UTC actual
    
    try {
        const ticketsSnapshot = await db.collectionGroup("tickets").get();

        if (ticketsSnapshot.empty) {
            console.log("No hay tickets vendidos en todo el sistema.");
            return;
        }

        const batch = db.batch();
        const eventsCache: { [key: string]: FirebaseFirestore.DocumentData } = {};

        for (const ticketDoc of ticketsSnapshot.docs) {
            const ticketData = ticketDoc.data();
            const eventId = ticketData.eventId;
            const userId = ticketDoc.ref.parent.parent?.id; 

            if (!eventId || !userId) continue;

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

            // =============================================================
            // FIX DE HORA PARA CARACAS (UTC-4)
            // =============================================================
            const fechaEvento = new Date(eventData.startDate);
            const startTime = eventData.startTime;

            if (startTime && typeof startTime.hour !== 'undefined') {
                // Sumamos 4 horas para convertir la hora de Caracas a UTC
                // Así 3:00 AM Caracas se convierte en 7:00 AM UTC
                fechaEvento.setUTCHours(startTime.hour + 4);
                fechaEvento.setUTCMinutes(startTime.minute || 0);
            }

            const diffEnMilisegundos = fechaEvento.getTime() - now.getTime();
            const diffEnHoras = diffEnMilisegundos / (1000 * 60 * 60);

            console.log(`Analizando: ${eventData.name} | Usuario: ${userId}`);
            console.log(`Hora Caracas: ${startTime.hour}:${startTime.minute}`);
            console.log(`Hora UTC calculada: ${fechaEvento.toISOString()}`);
            console.log(`Diferencia real: ${diffEnHoras} horas`);

            if (diffEnHoras > 0 && diffEnHoras <= 24) {
                const notifId = `${userId}_${eventId}_24h`;
                const notifRef = db.collection("notifications").doc(notifId);

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

        await batch.commit();
        console.log("✅ Revisión de eventos próximos completada.");

    } catch (error) {
        console.error("❌ Error en el cron job:", error);
    }
});