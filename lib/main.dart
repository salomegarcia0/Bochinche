import 'package:bochinche_app/data/firebase_options.dart';
// import 'package:bochinche_app/features/auth/SignUpScreen.dart';
// import 'package:bochinche_app/features/auth/loginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/map/mapa.dart';
import 'features/auth/SignUpScreen.dart';
import 'features/map/Paginna_Inicio.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase usando las opciones de tu archivo firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.signOut();

  debugPrint("Conectado a Firebase: ${Firebase.app().name}");

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
      home: const Pagina_Principal(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Mapa mapa = const Mapa();

  @override
  Widget build(BuildContext context) {
    return mapa;
  }
}
