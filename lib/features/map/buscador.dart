import 'package:bochinche_app/styles/Color.dart';
import 'package:flutter/material.dart';

class buscador extends StatelessWidget implements PreferredSizeWidget {
  const buscador({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Stack();
  }

  Widget iconpersona(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.person, color: SecondaryPurple),
      onPressed: () {
        // mostrara una ventana emergente al presionar el icono
      },
    );
  }

  Widget icon(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: SecondaryPurple),
      onPressed: () {
        // mostrara una ventana emergente lateral al presionar el icono
      },
    );
  }
}
