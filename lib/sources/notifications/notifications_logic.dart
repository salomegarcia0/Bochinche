import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsLogic {
  Stream<List<Map<String, dynamic>>> getFollowingEventsNotifications(
    String currentUserUid,
  ) {
    // 1. Obtenemos el documento del usuario actual para ver a quién sigue
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .snapshots()
        .asyncMap((userDoc) async {
          List<dynamic> following = userDoc.data()?['following'] ?? [];

          if (following.isEmpty) return [];

          QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
              .collection('events')
              .where('id_organizer', whereIn: following)
              .orderBy('createdAt', descending: true)
              .limit(10)
              .get();

          return eventSnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Future<void> notifyFollowers({
    required String organizerId,
    required String eventName,
    required String eventType,
  }) async {
    QuerySnapshot followersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('following', arrayContains: organizerId)
        .get();

    if (followersSnapshot.docs.isEmpty)
      return; // Nadie lo sigue, no hacemos nada

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var doc in followersSnapshot.docs) {
      DocumentReference notifRef = FirebaseFirestore.instance
          .collection('notifications')
          .doc();

      batch.set(notifRef, {
        'id_not': notifRef.id,
        'receiverId': doc.id, // El ID del usuario que lo sigue
        'title': '¡Nuevo evento de !',
        'message': 'Se ha publicado: $eventName. ¡No te lo pierdas!',
        'timestamp': FieldValue.serverTimestamp(),
        'type': eventType,
        'read': false,
      });
    }

    await batch.commit();
  }
}
