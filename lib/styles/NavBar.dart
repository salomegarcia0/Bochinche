import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/map/Paginna_Inicio.dart'; // Asegúrate que el nombre del archivo sea correcto
import 'package:bochinche_app/sources/events/events_ui.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/sources/reports/reports_ui.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'guest';
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.data()?['rol'] ?? 'organizador';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<String>(
        future: _getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final String userRole = snapshot.data ?? 'organizador';

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.purple),
                child: Text(
                  'BOCHINCHE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildListTile(
                context,
                Icons.explore,
                'Explorar eventos',
                const PublicEventsScreen(),
              ),
              _buildListTile(
                context,
                Icons.map,
                'Mapa',
                const Pagina_Principal(),
              ),
              _buildListTile(
                context,
                Icons.add_circle,
                'Crear eventos',
                const EventosCreate(),
              ),
              _buildListTile(
                context,
                Icons.dashboard,
                'Mis eventos',
                const ControlPanelEvent(),
              ),

              // FIX: En ListView children, el if no lleva llaves {}
              if (userRole == 'admin')
                _buildListTile(
                  context,
                  Icons.admin_panel_settings,
                  'Administrar Reportes',
                  const AdminReports(),
                ),

              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  clearAllFields();
                  await FirebaseAuth.instance.signOut();
                  // FIX: Verificación de context.mounted antes de navegar después de un await
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      onTap: () {
        clearAllFields();
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}
