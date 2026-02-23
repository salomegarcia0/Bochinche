import 'package:bochinche_app/data/firebase_options.dart';
import 'package:bochinche_app/features/authentication/authentication_steps.dart';
// import 'package:bochinche_app/features/auth/SignUpScreen.dart';
// import 'package:bochinche_app/features/auth/loginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/map/mapa.dart';
import 'features/map/Paginna_Inicio.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase usando las opciones de tu archivo firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await FirebaseAuth.instance.signOut();
  debugPrint("Conectado a Firebase: ${Firebase.app().name}");

  await Supabase.initialize(
    url: 'https://mnsffmoscncicppdmumh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1uc2ZmbW9zY25jaWNwcGRtdW1oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzNTEzNzIsImV4cCI6MjA4NjkyNzM3Mn0.OMfxVszd2T-dKTq-fncwGfvzRNLbtR0JxO2Hm_zjDVE',
  );

  debugPrint("Sistemas iniciados correctamente: Firebase y Supabase");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      debugShowCheckedModeBanner: false,
      home: const Authetication_steps(),
    );
  }
}
