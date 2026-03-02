import 'package:bochinche_app/data/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class UserProfileLogic {
  Future<Map<String, dynamic>?> chargeProfileOrg(String uid1) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }

  Future<List<QueryDocumentSnapshot>> getEventsByOrganizer(String uid1) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('id_organizer', isEqualTo: uid1)
        .where('isPrivate', isEqualTo: false)
        .get();

    return snapshot.docs;
  }

  Future<void> followOrganizer(
    String currentUserId,
    String organizerId,
    bool isFollowing,
  ) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId);

    if (isFollowing) {
      await userRef.update({
        'following': FieldValue.arrayUnion([organizerId]),
      });
    } else {
      await userRef.update({
        'following': FieldValue.arrayRemove([organizerId]),
      });
    }
  }

  Future<bool> checkIfFollowing(String currentUid, String organizerUid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .get();

      if (doc.exists) {
        List<dynamic> following = doc.data()?['following'] ?? [];
        return following.contains(organizerUid);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
