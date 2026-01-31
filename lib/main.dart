import 'package:bochinche_app/data/firebase_options.dart';
import 'package:bochinche_app/sources/events/events_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Asegura que Flutter esté listo para servicios como Firebase y Mapas
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase usando las opciones de tu archivo firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint("Conectado a Firebase: ${Firebase.app().name}");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bochinche App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // CORRECCIÓN: Se agrega "ColorScheme" antes del punto
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Tu pantalla principal ahora es EventosCreate
      home: const EventosCreate(),
    );
  }
}
