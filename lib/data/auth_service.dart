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

  // LOGIN CON SINCRONIZACIÓN DE CORREO //
  Future<User?> signInWithEmailAndPassword(
    String emailOrUsername, // <-- AHORA ACEPTA AMBOS
    String password,
  ) async {
    try {
      String finalEmail = emailOrUsername.trim();

      // ========================================================
      // MAGIA: SI NO TIENE '@', ASUMIMOS QUE ES UN USERNAME
      // ========================================================
      if (!finalEmail.contains('@')) {
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('username_lowercase', isEqualTo: finalEmail.toLowerCase())
            .limit(1)
            .get();

        // Si no hay nadie con ese username, cortamos de raíz
        if (result.docs.isEmpty) {
          throw "Usuario no encontrado"; 
        }

        // Si lo encontramos, sacamos su correo de la base de datos
        finalEmail = result.docs.first.get('email');
      }
      // ========================================================

      // 1. Intentamos el login normal (usando el correo final)
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: finalEmail,
        password: password,
      );

      if (result.user != null) {
        // 2. FORZAMOS el refresco de los datos del usuario (VITAL)
        await result.user!.reload();
        User? userActualizado = _auth.currentUser; 

        // 3. Si Firebase Auth dice que ya está verificado, actualizamos Firestore
        if (userActualizado != null && userActualizado.emailVerified) {
          await _firestore.collection('users').doc(userActualizado.uid).update({
            'email_verified': true,
          });
          print("✅ Firestore sincronizado: email_verified ahora es true");
        }

        // 4. Actualizamos el token de notificaciones
        await _actualizarFCMToken(result.user!.uid);
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Error en Firebase";
    } catch (e) {
      // Pasamos el error exacto si es que el usuario no existe
      if (e.toString() == "Usuario no encontrado") {
        throw e.toString();
      }
      throw "Error de conexión o datos inválidos";
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

  // --- NUEVA FUNCIÓN: VERIFICAR DISPONIBILIDAD DEL USERNAME ---
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final String usernameLower = username.toLowerCase();
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('username_lowercase', isEqualTo: usernameLower)
          .limit(1)
          .get();
          
      // Si está vacío, significa que el username está disponible (true)
      return result.docs.isEmpty;
    } catch (e) {
      print("Error verificando username: $e");
      throw "Error al verificar la disponibilidad del usuario";
    }
  }

  // REGISTRO //
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String username,
    required String rol,
    String? cedula,
    String? phone,
  }) async {
    try {
      // 1. Verificamos que el username no esté tomado antes de crear nada
      bool isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        throw "El nombre de usuario ya está en uso"; // Esto lo atrapará el try-catch de la UI
      }

      // 2. Si está libre, creamos el usuario en Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.sendEmailVerification();
        await credential.user!.reload();
      }

      String uid = credential.user!.uid;

      // 3. Guardamos los datos en Firestore, incluyendo las dos versiones del username
      Map<String, dynamic> userData = {
        'uid': uid,
        'nombre': name,
        'username': username, // Ej: ImSateXx
        'username_lowercase': username.toLowerCase(), // Ej: imsatexx
        'email': email,
        'rol': rol,
        'telefono': phone,
        'fecha_creacion': FieldValue.serverTimestamp(),
        'cedula': cedula,
        'verification_status': 'unverified', 
        'email_verified': false,
      };

      await _firestore.collection('users').doc(uid).set(userData);
      await _actualizarFCMToken(uid);
      return credential.user;
      
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Error al registrar usuario";
    } catch (e) {
      // Si el error es el que lanzamos nosotros (username en uso), lo pasamos tal cual
      if (e.toString().contains("nombre de usuario ya está en uso")) {
        throw e.toString();
      }
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