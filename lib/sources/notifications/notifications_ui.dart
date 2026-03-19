import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/styles/Color.dart';

void showNotifications(
  BuildContext context, {
  required Function(Map<String, dynamic>) onEventSelected,
}) {
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
                  // ==========================================
                  // BOTÓN DE LIMPIAR ARREGLADO
                  // ==========================================
                  onPressed: () async {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId == null) return;

                    final batch = FirebaseFirestore.instance.batch();
                    
                    // Buscamos todas las notificaciones de este usuario
                    final notificationsSnapshot = await FirebaseFirestore.instance
                        .collection('notifications')
                        .where('userId', isEqualTo: userId) // CAMBIADO: Antes decía receiverId
                        .get();

                    if (notificationsSnapshot.docs.isEmpty) return;

                    // Las metemos en la bolsa de basura (borrado en lote)
                    for (var doc in notificationsSnapshot.docs) {
                      batch.delete(doc.reference);
                    }

                    // Tiramos la basura
                    await batch.commit();
                  },
                  child: const Text(
                    "Limpiar",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    // CAMBIADO: Usamos 'userId' porque así lo guarda tu backend
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: PrimaryPurple),
                    );
                  }

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
                          "No hay notificaciones",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>? ?? {};

                      final String type = data['type']?.toString() ?? 'general';
                      final String title = data['titulo']?.toString() ?? 'Sin título'; // CAMBIADO a 'titulo' (como en backend)
                      final String message = data['mensaje']?.toString() ?? ''; // CAMBIADO a 'mensaje' (como en backend)
                      final String eventId = data['eventId']?.toString() ?? '';

                      bool isRecordatorio = type == 'recordatorio_tiempo';
                      Color iconColor = isRecordatorio ? Colors.orange : PrimaryPurple;
                      Color bgColor = iconColor.withOpacity(0.05);

                      return InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () async {
                          if (eventId.isNotEmpty) {
                            DocumentSnapshot eventDoc = await FirebaseFirestore.instance
                                .collection('events')
                                .doc(eventId)
                                .get();

                            if (eventDoc.exists) {
                              Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
                              eventData['id'] = eventDoc.id;

                              if (context.mounted) {
                                Navigator.pop(context); // Cierra el bottom sheet
                                onEventSelected(eventData); // Abre la rumba
                              }
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: iconColor.withOpacity(0.2),
                              child: Icon(
                                isRecordatorio ? Icons.access_alarm : Icons.celebration,
                                color: iconColor,
                              ),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                message,
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              ),
                            ),
                            // El Trailing ahora es una X sutil para borrar solo esa notificación
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                              onPressed: () {
                                doc.reference.delete(); // Borra solo este documento
                              },
                            ),
                          ),
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
