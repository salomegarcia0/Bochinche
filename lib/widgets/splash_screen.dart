import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bochinche_app/features/map/pagina_inicio.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate initial loading or just show the logo for a while
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Pagina_Principal()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF330033), // Branded dark purple
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/logo_bochinche.png',
                width: 250,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback in case the image is not found
                  return const Icon(
                    Icons.celebration,
                    color: Color(0xFFFFB822),
                    size: 100,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Optional: Loading indicator or tagline
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB822)),
            ),
          ],
        ),
      ),
    );
  }
}
