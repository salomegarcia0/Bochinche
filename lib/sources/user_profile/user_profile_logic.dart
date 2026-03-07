import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<double> getStarsUser(String uid1) async {
    if (uid1.isEmpty) return 0.0;

    try {
      // 1. Referencia a la colección de eventos
      // Nota: Asegúrate de tener un campo 'userId' o similar en el documento para filtrar
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where(
            'id_organizer',
            isEqualTo: uid1,
          ) // Filtramos por el ID del usuario
          .get();

      if (querySnapshot.docs.isEmpty) return 0.0;

      double totalStars = 0;
      double count = 0;

      // 2. Iterar y sumar las estrellas
      for (var doc in querySnapshot.docs) {
        // Usamos 'as dynamic' o mapeamos para evitar errores de tipo
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Sumamos el valor de 'stars' (asegurándonos de que sea numérico)
        totalStars += (data['stars'] ?? 0).toDouble();
        count += (data['total_review'] ?? 0).toDouble();
      }

      if (count != 0.0) {
        print(totalStars);
        print(count);
        return totalStars / count;
      } else {
        return 0.0;
      }
    } catch (e) {
      print("Error al obtener estrellas: $e");
      return 0.0;
    }
  }
}
