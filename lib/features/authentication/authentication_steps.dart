import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:flutter/material.dart';

class Authetication_steps extends StatefulWidget
    implements PreferredSizeWidget {
  const Authetication_steps({super.key});

  @override
  State<Authetication_steps> createState() => _Authetication_steps();

  @override
  Size get preferredSize => const Size.fromHeight(300);
}

class _Authetication_steps extends State<Authetication_steps> {
  File? selfie;
  File? ID;
  final ImagePicker _picker = ImagePicker();
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const Text(
              "Sube tu Identificación (ID)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ID != null
                ? Image.file(ID!, height: 150)
                : const Icon(Icons.perm_identity, size: 100),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery, false),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("ID"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera, false),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Selfie"),
                ),
              ],
            ),

            const Divider(height: 40),

            // Botón de Verificación Final
            ElevatedButton(
              onPressed: (selfie != null && ID != null) ? verification : null,
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              child: const Text("Verificar Identidad"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, bool isSelfie) async {
    final XFile? selectedImage = await _picker.pickImage(
      source: source,
      imageQuality: 50, // Comprimimos un poco para que no pese tanto al subir
    );

    if (selectedImage != null) {
      setState(() {
        if (isSelfie) {
          selfie = File(selectedImage.path);
        } else {
          ID = File(selectedImage.path);
        }
      });
    }
  }

  void verification() {}
}
