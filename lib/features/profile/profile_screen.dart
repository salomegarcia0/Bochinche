import 'package:bochinche_app/data/user_model.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  UserModel? _usuario;
  bool _cargando = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        Container(color: PrimaryBackGroundPurple),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Mi Perfil",
                style: TextStyle(
                    color: SecondaryPurple, fontWeight: FontWeight.bold)),
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
              ? const Center(
                  child: CircularProgressIndicator(color: SecondaryPurple))
              : _usuario == null
                  ? const Center(
                      child: Text("Error al cargar perfil",
                          style: TextStyle(color: Colors.white)))
                  : Column(
                      children: [
                        const SizedBox(height: 20),
                        // VISTA PRINCIPAL (Foto y Nombre) 
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: SecondaryPurple,
                          backgroundImage: _usuario!.profileImageUrl != null
                              ? NetworkImage(_usuario!.profileImageUrl!)
                              : null,
                          child: _usuario!.profileImageUrl == null
                              ? const Icon(Icons.person,
                                  size: 50, color: PrimaryPurple)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _usuario!.nombre,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        // BOTON PARA EDITAR
                        ElevatedButton.icon(
                          onPressed: () {
             
                            print("Editar perfil presionado");
                          },
                          icon: const Icon(Icons.edit,
                              size: 16, color: PrimaryPurple),
                          label: const Text("Editar Perfil",
                              style: TextStyle(color: PrimaryPurple)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: SecondaryPurple),
                        ),
                        const SizedBox(height: 20),
                        // PESTAÑAS (Eventos)
                        TabBar(
                          controller: _tabController,
                          labelColor: SecondaryPurple,
                          unselectedLabelColor: Colors.white60,
                          indicatorColor: SecondaryPurple,
                          tabs: const [
                            Tab(text: "Por Realizar"),
                            Tab(text: "Realizados"),
                            Tab(text: "Privados"),
                          ],
                        ),
                        // CONTENIDO DE PESTAÑAS
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildEventList("proximos"),
                              _buildEventList("pasados"),
                              _buildEventList("privados"),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  // Widget temporal para listar eventos
  Widget _buildEventList(String tipo) {
    return Center(
      child: Text(
        "Lista de eventos: $tipo",
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}



  



