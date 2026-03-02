import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/styles/Color.dart';

void showNotifications(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Permite que el modal crezca si es necesario
    backgroundColor: Colors.transparent, // Para usar nuestro propio estilo
    builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        height: MediaQuery.of(context).size.height * 0.7, // Un poco más alto
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Barra gris de agarre (estética de modal moderna)
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
                // Botón para marcar como leídas o limpiar (opcional)
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: PrimaryPurple),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      // Detectamos si es un tipo "nuevo_evento" para cambiar el icono
                      bool isNewEvent = doc['type'] == 'nuevo_evento';

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
                            doc['title'] ?? 'Sin título',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc['message'] ?? '',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Hace un momento", // Aquí podrías formatear el timestamp
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Lógica para ir al evento o perfil
                          },
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
