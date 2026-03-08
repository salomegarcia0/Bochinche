import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/map/pagina_inicio.dart';
import 'package:bochinche_app/sources/events/events_ui.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/features/Registered Events/registered_events.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
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
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Explorar eventos'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const PublicEventsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Mapa'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const PaginaPrincipal()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.local_activity),
            title: const Text('Mis Entradas'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const registered_events()),
            ),
          ),
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
      ),
    );
  }
}
