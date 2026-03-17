import 'package:flutter/material.dart';
import 'venezuelan_payment_screen.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planes Bochinche"),
        backgroundColor: Colors.amber[700],
      ),
      body: SingleChildScrollView(
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
