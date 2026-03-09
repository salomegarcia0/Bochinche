import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/features/map/mapa_principal.dart';
import 'package:flutter/material.dart';
import 'package:bochinche_app/features/map/BuscadorEventoMapa.dart';
import 'package:bochinche_app/widgets/NavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';

class Pagina_Principal extends StatefulWidget {
  const Pagina_Principal({super.key});
  @override
  State<Pagina_Principal> createState() => _Pagina_PrincipalState();
}

class _Pagina_PrincipalState extends State<Pagina_Principal> {
  final GlobalKey<MapaPrincipalState> _mapaKey =
      GlobalKey<MapaPrincipalState>();

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
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: MapaPrincipal(
                key: _mapaKey,
              ), // <--- Usando el nuevo nombre
            ),
          ),

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
    );
  }
}
