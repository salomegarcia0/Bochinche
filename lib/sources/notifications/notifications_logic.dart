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

  Future<void> markAllNotificationsAsRead(String userId) async {
    final firestore = FirebaseFirestore.instance;

    final unreadNotificationsQuery = await firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    WriteBatch batch = firestore.batch();

    for (var doc in unreadNotificationsQuery.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();
  }

  Future<void> notifyFollowersOfNewEvent(
    String organizerId,
    String eventId,
    String eventName,
    String organizerName, // Pasamos el nombre por parámetro
  ) async {
    final firestore = FirebaseFirestore.instance;

    // 1. Buscar a todos los usuarios que tengan al organizador en su lista 'following'
    QuerySnapshot usersFollowingQuery = await firestore
        .collection('users')
        .where('following', arrayContains: organizerId)
        .get();

    if (usersFollowingQuery.docs.isEmpty) return;

    // 2. Crear el lote de escritura
    WriteBatch batch = firestore.batch();

    for (var userDoc in usersFollowingQuery.docs) {
      String followerId = userDoc.id;
      DocumentReference notifRef = firestore.collection('notifications').doc();

      batch.set(notifRef, {
        'userId': followerId,
        'type': 'new_event',
        'message': '$organizerName ha creado un nuevo evento: $eventName',
        'eventId': eventId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // 3. Confirmar la operación
    await batch.commit();
  }
}
