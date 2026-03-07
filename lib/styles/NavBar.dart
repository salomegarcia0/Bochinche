import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/map/pagina_inicio.dart';
import 'package:bochinche_app/sources/reports/reports_ui.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bochinche_app/sources/events/events_ui.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'guest';

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data()!['rol'];
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

          final String role = snapshot.data ?? 'organizador';
          final bool isOrganizador = role == 'admin';

          return ListView(
            children: [
              _buildListTile(
                context,
                Icons.map,
                'Mapa',
                const Pagina_Principal(),
              ),
              _buildListTile(
                context,
                Icons.create,
                'Crear eventos',
                const EventosCreate(),
              ),
              _buildListTile(
                context,
                Icons.view_array,
                'Panel de control',
                const ControlPanelEvent(),
              ),
              _buildListTile(
                context,
                Icons.report,
                'Ver mis reportes',
                MyReports(),
              ),

              if (isOrganizador) ...[
                _buildListTile(
                  context,
                  Icons.report_problem,
                  'Administrar reportes',
                  const AdminReports(),
                ),
              ],

              if (role == 'guest')
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Iniciar sesión'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar sesión'),
                  onTap: () {
                    clearAllFields();
                    FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
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
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        clearAllFields();
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}
