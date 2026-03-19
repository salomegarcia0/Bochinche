import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/map/pagina_inicio.dart';
import 'package:bochinche_app/sources/events/events_ui.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/sources/reports/reports_ui.dart';
import 'package:bochinche_app/features/Registered Events/registered_events.dart';
import 'package:bochinche_app/sources/statistics/statistics_ui.dart';
import 'package:bochinche_app/styles/Color.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'guest';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['rol'] ?? 'usuario';
    } catch (e) {
      return 'usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<String>(
        future: _getUserRole(),
        builder: (context, snapshot) {
          final role = snapshot.data ?? 'usuario';

          // ========================================================
          // SEPARAMOS LOS ROLES PARA EL NAVBAR
          // ========================================================
          final bool isAdmin = role == 'admin';
          final bool isOrganizer = role == 'organizador';

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: PrimaryPurple),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BOCHINCHE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      FirebaseAuth.instance.currentUser?.displayName ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // ========================================================
              // VISTA EXCLUSIVA PARA EL ADMIN
              // ========================================================
              if (isAdmin) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
                  child: Text(
                    "CUARTEL GENERAL",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                _item(
                  context,
                  Icons.query_stats,
                  'Estadísticas',
                  const StatisticsScreen(),
                ),
                _item(
                  context,
                  Icons.report_problem,
                  'Administrar reportes',
                  const AdminReports(),
                ),
              ]
              // ========================================================
              // VISTA PARA USUARIOS Y ORGANIZADORES
              // ========================================================
              else ...[
                _item(
                  context,
                  Icons.explore,
                  'Explorar',
                  const PublicEventsScreen(),
                ),
                _item(context, Icons.map, 'Mapa', const Pagina_Principal()),
                _item(
                  context,
                  Icons.local_activity,
                  'Mis Entradas',
                  const registered_events(),
                ),
                _item(context, Icons.report, 'Mis Reportes', const MyReports()),

                // Bloque extra solo si es Organizador
                if (isOrganizer) ...[
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
                    child: Text(
                      "GESTIÓN",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  _item(
                    context,
                    Icons.add_circle,
                    'Crear eventos',
                    const EventosCreate(),
                  ),
                  _item(
                    context,
                    Icons.dashboard,
                    'Panel de control',
                    const ControlPanelEvent(),
                  ),
                  _item(
                    context,
                    Icons.query_stats,
                    'Estadísticas',
                    const StatisticsScreen(),
                  ),
                ],
              ],

              // ========================================================
              // BOTÓN CERRAR SESIÓN (Común para todos)
              // ========================================================
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  clearAllFields();
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (c) => const LoginScreen()),
                      (r) => false,
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

  Widget _item(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: PrimaryPurple),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Cierra el menú
        Navigator.push(context, MaterialPageRoute(builder: (c) => page));
      },
    );
  }
}
