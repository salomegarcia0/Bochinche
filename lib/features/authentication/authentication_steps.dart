import 'package:bochinche_app/styles/Color.dart';
import 'package:flutter/material.dart';
import 'package:bochinche_app/features/authentication/authentication.dart';

class Authetication_steps extends StatefulWidget {
  const Authetication_steps({super.key});

  @override
  State<Authetication_steps> createState() => _Authetication_stepsState();
}

class _Authetication_stepsState extends State<Authetication_steps> {
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
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      const Text(
                        "Verificación de Identidad",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: PrimaryPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Sigue estas instrucciones para asegurar una validación rápida.",
                        style: TextStyle(color: PrimaryBackGroundPurple),
                      ),
                      const SizedBox(height: 30),

                      // Sección Cédula
                      _buildStepInstruction(
                        icon: Icons.badge_outlined,
                        title: "1. Foto de tu Cédula (ID)",
                        instructions: [
                          "Coloca el documento en posición horizontal.",
                          "Asegúrate de que todo el borde sea visible.",
                          "Evita reflejos de luz directos sobre el plástico.",
                          "Mantén la cámara centrada y enfocada.",
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Sección Selfie
                      _buildStepInstruction(
                        icon: Icons.face_retouching_natural,
                        title: "2. Tómate una Selfie",
                        instructions: [
                          "Busca un lugar con buena iluminación natural.",
                          "Retira gorras, lentes de sol o accesorios.",
                          "Evita el uso de maquillaje excesivo o filtros.",
                          "Mantén una expresión neutral y mira a la cámara.",
                        ],
                      ),

                      const Spacer(), // Empuja el botón hacia abajo
                      const Divider(height: 40),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Authetication(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          backgroundColor: PrimaryBackGroundPurple,
                          foregroundColor: AccentPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Entendido, Siguiente",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildStepInstruction({
    required IconData icon,
    required String title,
    required List<String> instructions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 28),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: instructions.map<Widget>(
                  (step) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "• ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            step,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
