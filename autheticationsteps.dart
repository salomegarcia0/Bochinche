import 'package:bochinche_app/styles/Color.dart';
import 'package:flutter/material.dart';
import 'package:bochinche_app/features/authentication/authentication.dart';

class Autheticationsteps extends StatefulWidget {
  const Autheticationsteps({super.key});

  @override
  State<Autheticationsteps> createState() => _AutheticationstepsState();
}

class _AutheticationstepsState extends State<Autheticationsteps> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrimaryBackGroundPurple,
      appBar: AppBar(
        title: const Text(
          "Autenticación de Usuario",
          style: TextStyle(color: SecondaryPurple, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        backgroundColor: PrimaryPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Container(
          decoration: BoxDecoration(
            color: AccentPurple,
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: cuerpo(context),
        ),
      ),
    );
  }

  Widget cuerpo(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      const Text(
                        "Sube tu Identificación (ID)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Tómate una Selfie",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Divider(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          Authetication();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Siguiente"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
