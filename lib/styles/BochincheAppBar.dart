import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';

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
        User? usuario = FirebaseAuth.instance.currentUser;

        if (usuario == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hola, ${usuario.displayName ?? 'Bochinchero'}")),
          );
        }
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
