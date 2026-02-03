import 'package:flutter/material.dart';
import 'package:bochinche_app/styles/Color.dart';

class BochincheAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BochincheAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: SecondaryPurple),
      title: const Text(
        'BOCHINCHE',
        style: TextStyle(color: SecondaryPurple, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: <Widget>[iconpersona(context)],
      actionsPadding: EdgeInsets.symmetric(horizontal: 16.0),

      backgroundColor: PrimaryPurple,
      elevation: 0,
    );
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
