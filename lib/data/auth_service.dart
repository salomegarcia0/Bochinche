import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    String? rif,
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
      };

      if (rol == 'organizador') {
        userData['rif'] = rif;
      } else {
        userData['cedula'] = cedula;
      }

      await _firestore.collection('users').doc(uid).set(userData);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Error al registrar usuario";
    } catch (e) {
      throw "Error de conexión o datos inválidos";
    }
  }

  // --- CERRAR SESION ---
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
