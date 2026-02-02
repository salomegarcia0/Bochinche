import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/features/map/Mapa.dart';
import 'package:flutter/material.dart';
import 'package:bochinche_app/features/map/BuscadorEventoMapa.dart';

class Pagina_Principal extends StatefulWidget {
  const Pagina_Principal({super.key});
  @override
  State<Pagina_Principal> createState() => _Pagina_PrincipalState();
}

class _Pagina_PrincipalState extends State<Pagina_Principal> {
  Mapa mapa = const Mapa();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BochincheAppBar(),
      body: Stack(
        children: [
          mapa,
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.5,
                child: const BuscadorEventoMapa(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
