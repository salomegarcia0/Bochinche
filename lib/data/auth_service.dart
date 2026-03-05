import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_messaging/firebase_messaging.dart";

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sincronizar Token FCM
  Future<void> _actualizarFCMToken(String uid) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(uid).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print("✅ Token FCM vinculado al usuario $uid");
      }
    } catch (e) {
      print("❌ Error al vincular Token FCM: $e");
    }
  }

  //LOGIN //
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        await _actualizarFCMToken(result.user!.uid);
      }
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Error en Firebase";
    } catch (e) {
      throw "Error de conexión odatos inválidos";
    }
  }

  Future<String?> getUserRol(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.get('rol'); // Devuelve 'usuario' o 'organizador'
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  //REGISTRO //
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String rol,
    String? cedula,
    String? phone,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
      }

      String uid = credential.user!.uid;

      Map<String, dynamic> userData = {
        'uid': uid,
        'nombre': name,
        'email': email,
        'rol': rol,
        'telefono': phone,
        'fecha_creacion': FieldValue.serverTimestamp(),
        'cedula': cedula,
        'verification_status': 'unverified', 
      };

      await _firestore.collection('users').doc(uid).set(userData);
      await _actualizarFCMToken(uid);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Error al registrar usuario";
    } catch (e) {
      throw "Error de conexión o datos inválidos";
    }
  }

  // --- CERRAR SESION ---
  Future<void> cerrarSesion() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': FieldValue.delete(),
        });
      }
      await _auth.signOut();
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }

  // Función para pedir la verificación (Cambia estado a 'pending')
  Future<void> solicitarVerificacion(String uid, Map<String, dynamic> formData) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'verification_status': 'pending',
        'verification_request_data': formData, 
      });
    } catch (e) {
      throw "Error al enviar el formulario de verificación";
    }
  }

  // Función para leer el estado actual (para saber qué botón mostrar)
  Stream<String> obtenerEstadoVerificacionStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data()!.containsKey('verification_status')) {
        return snapshot.get('verification_status');
      } else {
        return 'unverified';
      }
    });
  }
}
