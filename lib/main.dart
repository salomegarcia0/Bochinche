import 'package:bochinche_app/data/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/map/Paginna_Inicio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';  
import 'package:bochinche_app/widgets/detalle_evento.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'bochinche_alerts', 
  'Alertas de Bochinche', 
  description: 'Canal principal para avisos de rumbas y eventos.',
  importance: Importance.max,
);

// La Llave Maestra para navegar desde cualquier parte de la app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
        FirebaseFirestore.instance.collection('users').doc(uid).update({
            'fcmToken': newToken,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
    }
  });
  
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('¡Permiso concedido para notificaciones!');
    
    String? token = await messaging.getToken();
    
    debugPrint("-------------------------------------------------------");
    debugPrint("MI FCM TOKEN: $token");
    debugPrint("-------------------------------------------------------");

    if (token != null) {
      await _actualizarTokenEnFirestore(token);
    }
  }

  // 1. Inicializar las notificaciones locales para Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); 
      
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
      
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    // Escuchar clics cuando la app está ABIERTA y tocamos el banner
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        _navegarAEvento(response.payload!);
      }
    },
  );

  // 2. Crear el canal en el sistema Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 3. EL RADAR: Escuchar notificaciones cuando la app está ABIERTA (Foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        payload: message.data['eventId'], // Ocultamos el ID del evento aquí
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  // 4. Escuchar clics cuando la app está en SEGUNDO PLANO (Minimizada)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data['eventId'] != null) {
      _navegarAEvento(message.data['eventId']);
    }
  });

  // 5. Escuchar clics cuando la app estaba CERRADA (Terminated)
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null && initialMessage.data['eventId'] != null) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      _navegarAEvento(initialMessage.data['eventId']);
    });
  }

  debugPrint("Conectado a Firebase: ${Firebase.app().name}");

  await Supabase.initialize(
    url: 'https://mnsffmoscncicppdmumh.supabase.co',
    anonKey: 'TU_ANON_KEY_AQUI', 
  );

  runApp(const MyApp());
}

// =========================================================================
// EL ENRUTADOR: Descarga el evento y lanza el BottomSheet
// =========================================================================
Future<void> _navegarAEvento(String eventId) async {
  debugPrint("Navegando al evento con ID: $eventId");
  
  // Obtenemos el contexto actual desde la llave maestra
  final context = navigatorKey.currentContext;

  if (context != null) {
    try {
      // 1. Buscamos los datos del evento en la base de datos
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      if (eventDoc.exists) {
        Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
        
        // 2. Lanzamos tu función exacta pasándole el contexto, los datos y el ID
        mostrarDetalles(context, eventData, eventId);
      } else {
        debugPrint("El evento fue eliminado de la base de datos.");
      }
    } catch (e) {
      debugPrint("Error consultando el evento: $e");
    }
  } else {
    debugPrint("Error: navigatorKey.currentContext es null.");
  }
}

Future<void> _actualizarTokenEnFirestore(String token) async {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user != null) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'fcmToken': token,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          
      debugPrint("✅ Token sincronizado con el usuario: ${user.uid}");
    } catch (e) {
      debugPrint("❌ Error guardando el token: $e");
    }
  } else {
    debugPrint("ℹ️ Token obtenido, pero no hay usuario logueado todavía.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // VITAL: Le damos la llave a la app
      title: 'Bochinche App',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      debugShowCheckedModeBanner: false,
      home: const Pagina_Principal(),
    );
  }
}