import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PremiumService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  // Javier: Activa el premium guardando el tipo de plan (GOLD o DIAMOND)
  Future<bool> upgradeUserToPremium(String planType) async {
    try {
      if (userId == null) return false;

      await _db.collection('users').doc(userId).update({
        'isPremium': true,
        'planType': planType,
        'premiumSince': FieldValue.serverTimestamp(),
      });

      debugPrint("Javier: Usuario $userId ahora es Premium ($planType)");
      return true;
    } catch (e) {
      debugPrint("Javier: Error al actualizar premium en Firestore: $e");
      return false;
    }
  }
}
