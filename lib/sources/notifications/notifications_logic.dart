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
}