import 'package:bochinche_app/styles/Color.dart';
import 'package:flutter/material.dart';

class Authetication extends StatefulWidget implements PreferredSizeWidget {
  const Authetication({super.key});

  @override
  State<Authetication> createState() => _Authetication();

  @override
  Size get preferredSize => const Size.fromHeight(300);
}

class _Authetication extends State<Authetication> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Autenticacion",
          style: TextStyle(color: SecondaryPurple, fontWeight: FontWeight.bold),
        ),
      ),
      body: cuerpo(context),
    );
  }

  Widget cuerpo(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AccentPurple,
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: SecondaryPurple,
                  labelText: "indicacion1",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
