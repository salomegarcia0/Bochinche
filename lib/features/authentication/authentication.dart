import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class Authetication extends StatefulWidget {
  const Authetication({super.key});

  @override
  State<Authetication> createState() => _AutheticationState();
}

class _AutheticationState extends State<Authetication> {
  File? selfie;
  File? idFile;
  final ImagePicker _picker = ImagePicker();

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
                      Image(
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        image: (idFile != null)
                            ? FileImage(idFile!)
                            : AssetImage('lib/styles/id.png') as ImageProvider,
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera, false),
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                          idFile == null ? "Seleccionar ID" : "ID Cargado ✅",
                        ),
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        "Tómate una Selfie",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Image(
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        image: (selfie != null)
                            ? FileImage(selfie!)
                            : AssetImage('lib/styles/selfie.png')
                                  as ImageProvider,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera, true),
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                          selfie == null ? "Tomar Selfie" : "Selfie Cargada ✅",
                        ),
                      ),
                      const Spacer(),
                      const Divider(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          if (idFile == null || selfie == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Por favor, sube ambos archivos.",
                                ),
                              ),
                            );
                            return;
                          }
                          _subirVerificacion();
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
                          "Continuar",
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

  void alerta(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Obligamos a que use el botón
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("¡Verificación Enviada!"),
          content: const Text(
            "Tus documentos han sido cargados correctamente. Nuestro equipo los revisará pronto para habilitar tu insignia de organizador.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // 1. Cerramos el diálogo de alerta
                Navigator.pop(dialogContext);
                
                // 2. Cerramos la pantalla actual (Authetication)
                Navigator.pop(context);
                
                // 3. Cerramos la pantalla de instrucciones (Authetication_steps)
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PrimaryPurple,
                foregroundColor: AccentPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Volver a mi Perfil"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, bool isSelfie) async {
    final XFile? selectedImage = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (selectedImage != null) {
      setState(() {
        if (isSelfie) {
          selfie = File(selectedImage.path);
        } else {
          idFile = File(selectedImage.path);
        }
      });
    }
  }

  Future<void> _subirVerificacion() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: PrimaryPurple)),
    );

    try {
      // ID del usuario en Firebase Auth
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No hay usuario logueado");
      final String uid = user.uid;

      final supabase = Supabase.instance.client;
      final time = DateTime.now().millisecondsSinceEpoch;

      final selfiePath = '$uid/selfie_$time.jpg';
      final idPath = '$uid/documento_$time.jpg';

      //  Subimos a Supabase
      await supabase.storage.from('verificaciones').upload(selfiePath, selfie!);
      await supabase.storage.from('verificaciones').upload(idPath, idFile!);

      //  Supabase devuelve los links de las imágenes
      final selfieUrl = supabase.storage
          .from('verificaciones')
          .getPublicUrl(selfiePath);
      final idUrl = supabase.storage
          .from('verificaciones')
          .getPublicUrl(idPath);

      // Guardamos links en Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'url_selfie': selfieUrl,
        'url_documento': idUrl,
        'idProcessState': 'waiting',          
      });

      if (!mounted) return;
      Navigator.pop(context);

      alerta(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir los archivos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
