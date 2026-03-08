<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/map/Paginna_Inicio.dart'; // Asegúrate que el nombre del archivo sea correcto
import 'package:bochinche_app/sources/events/events_ui.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/sources/reports/reports_ui.dart';

=======
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/map/pagina_inicio.dart';
import 'package:bochinche_app/sources/reports/reports_ui.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bochinche_app/sources/events/events_ui.dart';
import 'package:bochinche_app/features/Registered Events/registered_events.dart'; 
import 'package:bochinche_app/features/Registered Events/registered_events.dart';

>>>>>>> origin/develop
class Navbar extends StatelessWidget {
  const Navbar({super.key});

  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'guest';
<<<<<<< HEAD
=======

>>>>>>> origin/develop
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
<<<<<<< HEAD
    return doc.data()?['rol'] ?? 'organizador';
=======

    return doc.data()!['rol'];
>>>>>>> origin/develop
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

<<<<<<< HEAD
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
=======
          final String role = snapshot.data ?? 'organizador';
          final bool isOrganizador = role == 'admin';

          return ListView(
            children: [
>>>>>>> origin/develop
              _buildListTile(
                context,
                Icons.map,
                'Mapa',
                const Pagina_Principal(),
              ),
<<<<<<< HEAD
              _buildListTile(
                context,
                Icons.add_circle,
=======
              
              // ---------------------------------------------------------
              // ¡NUEVO! Botón para ir a los eventos reservados (Mis Entradas)
              // ---------------------------------------------------------
              _buildListTile(
                context,
                Icons.local_activity, // Ícono de un ticket
                'Mis Entradas', 
                const registered_events(), // Asegúrate de que esta pantalla exista y esté importada correctamente
              ),
              // ---------------------------------------------------------

              _buildListTile(
                context,
                Icons.create,
>>>>>>> origin/develop
                'Crear eventos',
                const EventosCreate(),
              ),
              _buildListTile(
                context,
<<<<<<< HEAD
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
=======
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
                    // clearAllFields(); // Asegúrate de que esta función exista en este archivo o quítala si marca error
                    FirebaseAuth.instance.signOut();
>>>>>>> origin/develop
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
<<<<<<< HEAD
                  }
                },
              ),
=======
                  },
                ),
>>>>>>> origin/develop
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
<<<<<<< HEAD
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      onTap: () {
        clearAllFields();
=======
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        // Al tocar, navegamos a la pantalla seleccionada
>>>>>>> origin/develop
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> origin/develop
