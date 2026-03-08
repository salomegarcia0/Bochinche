import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bochinche_app/features/auth/SignUpScreen.dart';
import 'package:bochinche_app/features/map/pagina_inicio.dart'; // Asegúrate que el nombre del archivo sea este
import 'package:bochinche_app/data/auth_service.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/core/utils/draft_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool cargando = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final draft = await DraftManager.loadLoginDraft();
    if (mounted && draft != null) {
      setState(() {
        emailController.text = draft['email'] ?? '';
        passwordController.text = draft['password'] ?? '';
      });
    }
  }

  void ejecutarLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, ingresa tus credenciales")),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      // 1. Iniciar sesión en Firebase Auth
      User? user = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null && mounted) {
        // 2. Verificar si el usuario está baneado (Balance Develop)
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          bool estaBaneado = userData['banned'] ?? false;

          if (estaBaneado) {
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Tu cuenta ha sido suspendida. Contacta a soporte.",
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() => cargando = false);
              return;
            }
          }
        }

        // 3. Verificar si el correo está verificado
        if (user.emailVerified) {
          // ÉXITO: Sincronizar eventos y navegar (Balance Javier)
          await updateEventStatusOnLogin();
          DraftManager.clearLoginDraft();

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PaginaPrincipal()),
            );
          }
        } else {
          // Correo no verificado
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Verifica tu correo antes de ingresar."),
                backgroundColor: Colors.orange,
              ),
            );
            await user.sendEmailVerification();
            setState(() => cargando = false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al iniciar sesión: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrimaryBackGroundPurple,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AccentPurple,
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_pin,
                  size: 100,
                  color: PrimaryBackGroundPurple,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: SecondaryPurple,
                    labelText: "Correo Electrónico",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: SecondaryPurple,
                    labelText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => showPassword = !showPassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                cargando
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: ejecutarLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PrimaryBackGroundPurple,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "INICIAR SESIÓN",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const SignUpScreen()),
                  ),
                  child: const Text(
                    "¿No tienes cuenta? Regístrate aquí",
                    style: TextStyle(
                      color: PrimaryBackGroundPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
