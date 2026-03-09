import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/features/map/selector_ubicacion.dart';
import 'package:bochinche_app/features/map/BuscadorEventoMapa.dart';
import 'package:bochinche_app/styles/NavBar.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});
  @override
  State<PaginaPrincipal> createState() => PaginaPrincipalState();
}

class PaginaPrincipalState extends State<PaginaPrincipal> {
  final GlobalKey<SelectorUbicacionState> _mapaKey =
      GlobalKey<SelectorUbicacionState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateEventStatusOnLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: FirebaseAuth.instance.currentUser != null ? const Navbar() : null,
      appBar: const BochincheAppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: SelectorUbicacion(key: _mapaKey, esSelector: false),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: BuscadorEventoMapa(
                onSubmitted: (value) {
                  _mapaKey.currentState?.buscarPorCodigo(value.trim());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
