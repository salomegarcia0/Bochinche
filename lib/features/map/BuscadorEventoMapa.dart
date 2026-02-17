import 'package:bochinche_app/styles/Color.dart';
import 'package:flutter/material.dart';

class BuscadorEventoMapa extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onSearchCode;

  const BuscadorEventoMapa({super.key, this.onSearchCode});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Reducimos el margen inferior para evitar overflow y lo hacemos responsivo
      margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      decoration: BoxDecoration(
        color: PrimaryBackGroundPurple,
        borderRadius: BorderRadius.circular(35.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ajusta al contenido
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Container(), filtro(context)],
          ),
          buscador(context),
        ],
      ),
    );
  }

  Widget filtro(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
      child: FilledButton(
        onPressed: () {},
        style: FilledButton.styleFrom(
          backgroundColor: PrimaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        child: const Text('Filtros', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget buscador(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SecondaryPurple,
            borderRadius: BorderRadius.circular(50.0),
            border: Border.all(
              color: PrimaryPurple, // Color del borde
              width: 1.0, // Grosor
            ),
          ),
          child: TextField(
            scrollPadding: const EdgeInsets.all(8.0),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: PrimaryPurple),
              suffixIcon: IconButton(
                icon: const Icon(Icons.vpn_key, color: PrimaryPurple),
                tooltip: 'Buscar evento privado',
                onPressed: onSearchCode,
              ),
              hintText: 'Buscar evento',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
          ),
        ),
      ),
    );
  }
}
