import 'package:flutter/material.dart';
import 'venezuelan_payment_screen.dart';
import 'package:bochinche_app/features/profile/profile_screen.dart';
import 'package:bochinche_app/sources/notifications/notifications_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/widgets/detalle_evento.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Planes Bochinche",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber[700],
        centerTitle: true,
        actions: <Widget>[
          if (FirebaseAuth.instance.currentUser != null) iconbell(context),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.0),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Sube de nivel tu rumba",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // PLAN GOLD
              _buildPlanCard(
                context,
                title: "PLAN GOLD",
                price: "9.99",
                color: Colors.orange,
                icon: Icons.star,
                benefits: [
                  "Eventos Ilimitados",
                  "Insignia VIP",
                  "Sin publicidad",
                ],
              ),

              const SizedBox(height: 20),

              // PLAN DIAMOND
              _buildPlanCard(
                context,
                title: "PLAN DIAMOND",
                price: "19.99",
                color: Colors.blue.shade900,
                icon: Icons.diamond, // Javier: Corregido gem por diamond
                benefits: [
                  "Todo lo del Gold",
                  "Soporte 24/7",
                  "Eventos Destacados",
                ],
                isDiamond: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconbell(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.notifications,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      onPressed: () {
        User? usuario = FirebaseAuth.instance.currentUser;
        if (usuario == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          showNotifications(
            context,
            onEventSelected: (eventData) {
              mostrarDetalles(context, eventData, eventData['id']);
            },
          );
        }
      },
    );
  }

  Widget iconpersona(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.person, color: Color.fromARGB(255, 0, 0, 0)),
      onPressed: () {
        User? usuario = FirebaseAuth.instance.currentUser;

        if (usuario == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          // 🧹 Se eliminó el SnackBar de aquí
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
    );
  }

  Widget icon(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: SecondaryPurple),
      onPressed: () {
        // mostrara una ventana emergente lateral al presionar el icono
      },
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required Color color,
    required IconData icon,
    required List<String> benefits,
    bool isDiamond = false,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 50, color: color),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              "\$$price / mes",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...benefits
                .map(
                  (b) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(b),
                      ],
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDiamond
                      ? Colors.blue.shade900
                      : Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VenezuelanPaymentScreen(
                        planName: title,
                        price: price,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "SELECCIONAR",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
