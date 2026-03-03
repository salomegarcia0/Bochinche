import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/styles/Color.dart';

void showNotifications(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Barra gris de agarre
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Notificaciones",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: PrimaryPurple,
                  ),
                ),
                TextButton(
                  onPressed: () => print("Limpiar todo"),
                  child: const Text(
                    "Limpiar",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where(
                      'receiverId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                    )
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  // 1. Manejo de Errores (Si falta el índice, aquí verás el mensaje)
                  if (snapshot.hasError) {
                    print("ERROR FIRESTORE: ${snapshot.error}");
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: PrimaryPurple),
                    );
                  }

                  // 2. Extracción segura de documentos
                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "No hay notificaciones nuevas",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      // 3. Conversión segura a Map (Crucial para Web)
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>? ?? {};

                      // 4. Acceso seguro a campos con valores por defecto
                      final String type = data['type']?.toString() ?? 'general';
                      final String title =
                          data['title']?.toString() ?? 'Sin título';
                      final String message = data['message']?.toString() ?? '';

                      bool isNewEvent = type == 'nuevo_evento';

                      return Container(
                        decoration: BoxDecoration(
                          color: PrimaryPurple.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isNewEvent
                                ? Colors.orange[100]
                                : PrimaryPurple.withOpacity(0.2),
                            child: Icon(
                              isNewEvent
                                  ? Icons.celebration
                                  : Icons.notifications_active,
                              color: isNewEvent ? Colors.orange : PrimaryPurple,
                            ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Recibido ahora",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                            tooltip: 'Marcar como visto',
                            onPressed: () {
                              data['viewed'] = true;
                            },
                          ),
                          onTap: () {},
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
