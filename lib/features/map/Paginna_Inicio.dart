import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/features/map/Mapa.dart';
import 'package:flutter/material.dart';
import 'package:bochinche_app/features/map/BuscadorEventoMapa.dart';
import 'package:bochinche_app/styles/NavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';

class Pagina_Principal extends StatefulWidget {
  const Pagina_Principal({super.key});
  @override
  State<Pagina_Principal> createState() => _Pagina_PrincipalState();
}

class _Pagina_PrincipalState extends State<Pagina_Principal> {
  final GlobalKey<MapaState> _mapaKey = GlobalKey<MapaState>();

  @override
  Widget build(BuildContext context) {
    void initState() {
      super.initState();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateEventStatusOnLogin();
      });
    }

    return Scaffold(
      // El Drawer y el AppBar quedan fuera del detector de gestos
      drawer: FirebaseAuth.instance.currentUser != null ? const Navbar() : null,
      appBar: const BochincheAppBar(),

      body: GestureDetector(
        // Al estar aquí, solo cerrará el teclado cuando toques el mapa o áreas vacías del body
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Mapa(key: _mapaKey),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: BuscadorEventoMapa(
                  onSubmitted: (value) {
                    _mapaKey.currentState?.buscarPorCodigo(value.trim());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
