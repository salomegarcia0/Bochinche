import 'dart:io';
import 'package:bochinche_app/data/user_model.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel usuario;
  const EditProfileScreen({super.key, required this.usuario});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _identificationController;
  File? _imageFile;
  bool _subiendo = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.usuario.nombre);
    _phoneController = TextEditingController(text: widget.usuario.telefono);
    _identificationController = TextEditingController(text: widget.usuario.identification);
  }

  // --- SELECCIONAR IMAGEN ---
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // --- SUBIR IMAGEN A FIREBASE STORAGE ---
  Future<String?> _uploadImage() async {
    if (_imageFile == null) return widget.usuario.profileImageUrl;

    try {
      String fileName = 'profile_${widget.usuario.uid}.png';
      Reference ref = FirebaseStorage.instance.ref().child('profile_images').child(fileName);
      await ref.putFile(_imageFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error subiendo imagen: $e");
      return null;
    }
  }

  // --- GUARDAR CAMBIOS ---
  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _subiendo = true);

    String? imageUrl = await _uploadImage();

    UserModel usuarioActualizado = UserModel(
      uid: widget.usuario.uid,
      email: widget.usuario.email, // El correo no se edita asi
      nombre: _nameController.text,
      identification: _identificationController.text,
      telefono: _phoneController.text,
      profileImageUrl: imageUrl,
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.usuario.uid)
          .update(usuarioActualizado.toMap());
      
      if(mounted) Navigator.pop(context, true); // Regresar y refrescar
    } catch (e) {
      print("Error al actualizar: $e");
      setState(() => _subiendo = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al actualizar")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrimaryBackGroundPurple,
      appBar: AppBar(
        title: const Text("Editar Perfil", style: TextStyle(color: SecondaryPurple)),
        backgroundColor: PrimaryPurple,
        iconTheme: const IconThemeData(color: SecondaryPurple),
      ),
      body: _subiendo
          ? const Center(child: CircularProgressIndicator(color: SecondaryPurple))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- FOTO DE PERFIL ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: SecondaryPurple,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (widget.usuario.profileImageUrl != null
                                ? NetworkImage(widget.usuario.profileImageUrl!)
                                : null) as ImageProvider?,
                        child: _imageFile == null && widget.usuario.profileImageUrl == null
                            ? const Icon(Icons.camera_alt, size: 50, color: PrimaryPurple)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // --- CAMPOS ---
                    _buildTextField(_nameController, "Nombre / Razón Social", Icons.person),
                    _buildTextField(_identificationController, "Cédula / RIF", Icons.badge),
                    _buildTextField(_phoneController, "Teléfono", Icons.phone, TextInputType.phone),
                    const SizedBox(height: 30),
                    // --- BOTÓN GUARDAR ---
                    ElevatedButton(
                      onPressed: _guardarCambios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SecondaryPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: const Text("Guardar Cambios", style: TextStyle(color: PrimaryPurple, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: SecondaryPurple),
          prefixIcon: Icon(icon, color: SecondaryPurple),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: SecondaryPurple)),
        ),
        validator: (value) => value!.isEmpty ? "Este campo es requerido" : null,
      ),
    );
  }
}