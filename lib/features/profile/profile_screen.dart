import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bochinche_app/data/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _usuario; // Aca se va a guardar el usuario cargado desde Firebase
  bool _cargando = true;

  @override 
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (doc.exists) {
          setState(() {
            _usuario = UserModel.fromMap(
                doc.data() as Map<String, dynamic>, currentUser.uid);
            _cargando = false;
          });
        }
      } catch (e) {
        print("Error al obtener datos: $e");
        if (mounted) setState(() => _cargando = false);
      }
    }
  }

  void _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo
        Container(color: PrimaryBackGroundPurple),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              "Mi Perfil",
              style: TextStyle(color: SecondaryPurple, fontWeight: FontWeight.bold),
            ),
            backgroundColor: PrimaryPurple,
            centerTitle: true,
            elevation: 0,
            iconTheme: const IconThemeData(color: SecondaryPurple),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _cerrarSesion,
                tooltip: "Cerrar Sesión",
              )
            ],
          ),
          body: _cargando
              ? const Center(child: CircularProgressIndicator(color: SecondaryPurple))
              : _usuario == null
                  ? const Center(child: Text("No se encontró información del usuario", style: TextStyle(color: Colors.white)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Foto de perfil (Icono por ahora)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: SecondaryPurple,
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: PrimaryPurple,
                              backgroundImage: _usuario!.profileImageUrl != null
                                  ? NetworkImage(_usuario!.profileImageUrl!)
                                  : null,
                              child: _usuario!.profileImageUrl == null
                                  ? const Icon(Icons.person, size: 60, color: SecondaryPurple)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Tarjeta de Datos
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AccentPurple,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                _buildInfoItem("Nombre / Razón Social", _usuario!.nombre, Icons.person),
                                const Divider(color: PrimaryPurple),
                                _buildInfoItem("Correo", _usuario!.email, Icons.email),
                                const Divider(color: PrimaryPurple),
                                _buildInfoItem("Cédula / RIF", _usuario!.identification, Icons.badge),
                                const Divider(color: PrimaryPurple),
                                _buildInfoItem("Teléfono", _usuario!.telefono, Icons.phone),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  // Widget auxiliar para mostrar cada fila de datos
  Widget _buildInfoItem(String titulo, String valor, IconData icono) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icono, color: PrimaryBackGroundPurple, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  valor.isNotEmpty ? valor : "No especificado",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



  



