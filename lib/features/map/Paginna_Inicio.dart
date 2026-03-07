import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- IMPORTACIONES ABSOLUTAS (Para evitar rojos) ---
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/features/map/Mapa.dart';
import 'package:bochinche_app/features/map/BuscadorEventoMapa.dart';
import 'package:bochinche_app/styles/NavBar.dart';
import 'package:bochinche_app/sources/events/events_ui.dart';

class Pagina_Principal extends StatefulWidget {
  const Pagina_Principal({super.key});

  @override
  State<Pagina_Principal> createState() => _Pagina_PrincipalState();
}

class _Pagina_PrincipalState extends State<Pagina_Principal> {
  // Asegúrate que en Mapa.dart la clase sea MapaPrincipalState sin el "_"
  final GlobalKey<MapaPrincipalState> _mapaKey =
      GlobalKey<MapaPrincipalState>();

  @override
  void initState() {
    super.initState();
    // updateEventStatusOnLogin(); // Descomenta si ya existe en logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Quitamos 'const' para evitar conflictos de constructores
      drawer: FirebaseAuth.instance.currentUser != null ? Navbar() : null,
      appBar: const BochincheAppBar(),
      body: Stack(
        children: [
          Positioned.fill(child: MapaPrincipal(key: _mapaKey)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PublicEventsScreen(),
                    ),
                  );
                },
                child: const AbsorbPointer(child: BuscadorEventoMapa()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
