import 'package:bochinche_app/data/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/map/pagina_inicio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bochinche_app/widgets/detalle_evento.dart';
import 'package:bochinche_app/widgets/splash_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Javier: Importación del módulo Premium (Sprint 4)
import 'package:bochinche_app/features/premium/premium_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicialización de Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. JAVIER: Bloqueo de notificaciones para Web (Chrome) para evitar pantalla blanca
  if (!kIsWeb) {
    _inicializarNotificacionesMobile();
  } else {
    debugPrint(
      "--- JAVIER: MODO WEB ACTIVO. NOTIFICACIONES OMITIDAS PARA EVITAR CRASH ---",
    );
  }

  // 3. Inicialización de Supabase con tu AnonKey real
  try {
    await Supabase.initialize(
      url: 'https://mnsffmoscncicppdmumh.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1uc2ZmbW9zY25jaWNwcGRtdW1oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzNTEzNzIsImV4cCI6MjA4NjkyNzM3Mn0.OMfxVszd2T-dKTq-fncwGfvzRNLbtR0JxO2Hm_zjDVE',
    );
    debugPrint("Supabase conectado correctamente");
  } catch (e) {
    debugPrint("Error al conectar Supabase: $e");
  }

  runApp(const MyApp());
}

// Javier: Función separada para que el código de Adrián no rompa la web
void _inicializarNotificacionesMobile() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    String? token = await messaging.getToken();
    if (token != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (NotificationResponse res) {
        if (res.payload != null) _navegarAEvento(res.payload!);
      },
    );
  } catch (e) {
    debugPrint("Error en notificaciones: $e");
  }
}

// Javier: Navegación segura para eventos
Future<void> _navegarAEvento(String eventId) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .get();

    if (doc.exists) {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        mostrarDetalles(context, doc.data() as Map<String, dynamic>, eventId);
      }
    }
  } catch (e) {
    debugPrint("Javier: Error al navegar al evento: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Bochinche App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),

      // Javier: Ruta registrada para la pantalla de planes premium
      routes: {'/premium': (context) => const PremiumScreen()},
    );
  }
}
