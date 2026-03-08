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
                  onPressed: () {},
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
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>? ?? {};

                      final String type = data['type']?.toString() ?? 'general';
                      final String title =
                          data['title']?.toString() ?? 'Sin título';
                      final String message = data['message']?.toString() ?? '';
                      final String eventId = data['eventId']?.toString() ?? '';
                      final bool isRead = data['read'] == true;

                      bool isRecordatorio = type == 'recordatorio_tiempo';
                      Color iconColor = isRecordatorio
                          ? Colors.orange
                          : PrimaryPurple;
                      Color bgColor = isRead
                          ? Colors.transparent
                          : iconColor.withOpacity(0.05);

                      return InkWell(
                        borderRadius: BorderRadius.circular(15),
                        // ==========================================
                        // REDIRECCIÓN AL HACER CLICK
                        // ==========================================
                        onTap: () async {
                          doc.reference.update({'read': true});

                          if (eventId.isNotEmpty) {
                            DocumentSnapshot eventDoc = await FirebaseFirestore
                                .instance
                                .collection('events')
                                .doc(eventId)
                                .get();

                            if (eventDoc.exists) {
                              Map<String, dynamic> eventData =
                                  eventDoc.data() as Map<String, dynamic>;
                              eventData['id'] = eventDoc.id;

                              if (context.mounted) {
                                Navigator.pop(context);
                                onEventSelected(eventData);
                              }
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isRead
                                  ? Colors.grey.shade200
                                  : Colors.transparent,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: iconColor.withOpacity(0.2),
                              child: Icon(
                                isRecordatorio
                                    ? Icons.access_alarm
                                    : Icons.celebration,
                                color: iconColor,
                              ),
                            ),
                            title: Text(
                              title,
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                message,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            trailing: !isRead
                                ? const CircleAvatar(
                                    radius: 5,
                                    backgroundColor: PrimaryPurple,
                                  )
                                : const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 16,
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
