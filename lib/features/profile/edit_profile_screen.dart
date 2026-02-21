import 'dart:io';
import 'package:bochinche_app/data/user_model.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // --- 1. SELECCIONAR IMAGEN ---
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // --- 2. SUBIR A SUPABASE (Función Auxiliar) ---
  Future<String?> _subirImagenASupabase(File imagen) async {
    try {
      final fileName = 'user_${widget.usuario.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // A. Subir imagen
      await Supabase.instance.client.storage
          .from('profile_images') 
          .upload(fileName, imagen);

      // B. Obtener URL
      final imageUrl = Supabase.instance.client.storage
          .from('profile_images')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      debugPrint("Error subiendo a Supabase: $e");
      return null;
    }
  }

  // --- 3. GUARDAR TODO ---
  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _subiendo = true);

    try {
      // 1. URL actual por defecto
      String? finalImageUrl = widget.usuario.profileImageUrl;

      // 2. ¿Hay imagen nueva seleccionada?
      if (_imageFile != null) {
        // AQUÍ ES EL CAMBIO CLAVE:
        // Usamos la función de SUPABASE, no la de Firebase
        String? nuevaUrl = await _subirImagenASupabase(_imageFile!); 
        
        if (nuevaUrl != null) {
          finalImageUrl = nuevaUrl;
        }
      }

      // 3. Actualizamos los datos (Solo texto y link) en Firestore
      UserModel usuarioActualizado = UserModel(
        uid: widget.usuario.uid,
        email: widget.usuario.email,
        nombre: _nameController.text,
        identification: _identificationController.text,
        telefono: _phoneController.text,
        profileImageUrl: finalImageUrl,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.usuario.uid)
          .update(usuarioActualizado.toMap());
        
      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      print("Error: $e");
      // ... manejo de errores
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    // Lógica para decidir qué imagen mostrar
    ImageProvider? imagenMostrada;
    if (_imageFile != null) {
      imagenMostrada = FileImage(_imageFile!);
    } else if (widget.usuario.profileImageUrl != null && widget.usuario.profileImageUrl!.isNotEmpty) {
      imagenMostrada = NetworkImage(widget.usuario.profileImageUrl!);
    }

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
                    // --- FOTO ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: SecondaryPurple,
                        backgroundImage: imagenMostrada,
                        child: imagenMostrada == null
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
                    
                    // --- BOTÓN ---
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