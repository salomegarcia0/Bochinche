import 'package:bochinche_app/data/user_model.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/profile/edit_profile_screen.dart';
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
                        // VISTA PRINCIPAL 
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
                          onPressed: () async {
                            if (_usuario != null) {
                      
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(usuario: _usuario!),
                                ),
                              );
                              
                              
                              if (result == true) {
                                _cargarUsuario();
                              }
                            }
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
    if (_usuario == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
         
          .where('id_organizer', isEqualTo: _usuario!.uid) 
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar", style: TextStyle(color: Colors.white)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text("No has creado eventos", style: TextStyle(color: Colors.white54)));
        }

       
        final eventosFiltrados = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          
          
          String? fechaString = data['startDate']; 
          DateTime fechaEvento = DateTime.now();

          if (fechaString != null) {
            try {
              fechaEvento = DateTime.parse(fechaString);
            } catch (e) {
              print("Error al parsear fecha: $e");
            }
          }
          
          if (tipo == "proximos") {
            return fechaEvento.isAfter(DateTime.now().subtract(const Duration(days: 1)));
          } else if (tipo == "pasados") {
            return fechaEvento.isBefore(DateTime.now());
          } else if (tipo == "privados") {
            
            return false; 
          }
          return true;
        }).toList();

        if (eventosFiltrados.isEmpty) {
          return const Center(
            child: Text(
              "No hay eventos en esta sección",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          itemCount: eventosFiltrados.length,
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, index) {
            final doc = eventosFiltrados[index];
            final data = doc.data() as Map<String, dynamic>;
            
           
            final String? imagenUrl = data['image_url']; 

            
            String fechaTexto = "Sin fecha";
            if (data['startDate'] != null) {
              try {
                DateTime date = DateTime.parse(data['startDate']);
                
                fechaTexto = "${date.day}/${date.month}/${date.year}"; 
              } catch (_) {
                fechaTexto = data['startDate'].toString();
              }
            }

            return Card(
              color: Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imagenUrl != null && imagenUrl.isNotEmpty
                      ? Image.network(imagenUrl, width: 60, height: 60, fit: BoxFit.cover)
                      : Container(
                          width: 60, height: 60, 
                          color: PrimaryPurple,
                          child: const Icon(Icons.event, color: Colors.white),
                        ),
                ),
                
                title: Text(
                  data['name'] ?? "Evento sin nombre",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                subtitle: Text(
                  fechaTexto,
                  style: const TextStyle(color: Colors.black54),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => //_borrarEvento(doc.id),
                  print("borrar evento")
                ),
              ),
            );
          },
        );
      },
    );
  }
}




  



