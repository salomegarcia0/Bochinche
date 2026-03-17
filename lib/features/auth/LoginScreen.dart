import 'dart:async';
import 'package:bochinche_app/features/auth/SignUpScreen.dart';
import 'package:bochinche_app/features/map/pagina_inicio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/data/auth_service.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/core/utils/draft_manager.dart';
import 'package:bochinche_app/sources/statistics/statistics_ui.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

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
  
  // --- VALIDACIÓN ---
  Timer? _debounce;
  String? _emailError;
  String? _passwordError;

  bool cargando = false;
  bool showPassword = false;

  @override
  void dispose() {
    _debounce?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE VALIDACIÓN ---
  void _validateInput(String input) {
    setState(() {
      if (input.isEmpty) {
        _emailError = "El campo es requerido";
      } else if (!input.contains('@')) {
        // Si no tiene @, asumimos que es un username. Verificamos tamaño básico.
        if (input.length < 3) {
          _emailError = "Mínimo 3 caracteres para usuario";
        } else {
          _emailError = null;
        }
      } else {
        // Si tiene @, usamos la validación estricta de correo
        final bool emailValid = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(input);
        if (!emailValid) {
          _emailError = "El correo no es válido";
        } else {
          _emailError = null;
        }
      }
    });
  }

  void _validatePassword(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordError = "La contraseña es requerida";
      } else if (password.length < 6) {
        _passwordError = "Mínimo 6 caracteres";
      } else {
        _passwordError = null;
      }
    });
  }

  bool _validateAll() {
    _validateInput(emailController.text.trim());
    _validatePassword(passwordController.text);

    return _emailError == null && _passwordError == null;
  }

  void ejecutarLogin() async {
    if (!_validateAll()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, corrige los errores en el formulario"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      // 1. Iniciar sesión en Authentication (Pasando el correo O el username)
      User? user = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null && mounted) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get();
        bool estaBaneado = false;

        if (snapshot.docs.isNotEmpty) {
          var data = snapshot.docs.first.data() as Map<String, dynamic>;
          estaBaneado = data['banned'] ?? false;

          if (estaBaneado) {
            await FirebaseAuth.instance.signOut();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Tu cuenta ha sido suspendida. Contacta a soporte.",
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );

              setState(() => cargando = false);
              return;
            }
          }

          // Obtenemos el rol del usuario (Ej: 'organizador','admin')
          String? rol = await _authService.getUserRol(user.uid);

          if (rol != null && user.emailVerified == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Login exitoso!."),
                backgroundColor: Color.fromARGB(255, 17, 255, 9),
                duration: Duration(seconds: 4),
              ),
            );
            updateEventStatusOnLogin();
            DraftManager.clearLoginDraft();

            // ========================================================
            // LÓGICA DE DESVÍO DE RUTAS SEGÚN ROL
            // ========================================================
            if (rol == 'admin') {
              // El Admin va directo a las estadísticas.
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            } else {
              // Si es usuario u organizador normal, va al mapa de Bochinche
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Pagina_Principal()),
              );
            }
            // ========================================================

          } else {
            if (rol != null && user.emailVerified == false) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Verifica tu correo primero para iniciar sesión.",
                    ),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 4),
                  ),
                );
                user.sendEmailVerification();
                setState(() => cargando = false);
                return;
              }
            }
          }
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $error"),
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
    return Stack(
      children: [
        Container(color: PrimaryBackGroundPurple),

        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: const Text(
              "Iniciar Sesión",
              style: TextStyle(
                color: SecondaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            backgroundColor: PrimaryPurple,
            elevation: 0,
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [contenido(context)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget waitTilVerification(BuildContext context) {
    return Stack(
      children: [
        Container(color: PrimaryBackGroundPurple),

        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: const Text(
              "Espera la verificación de tu correo",
              style: TextStyle(
                color: SecondaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            backgroundColor: PrimaryPurple,
            elevation: 0,
          ),
          body: SafeArea(child: Center(child: Text('Espere unos segundos'))),
        ),
      ],
    );
  }

  Widget contenido(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AccentPurple,
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                //Se va a cambiar por el logo de la app
                child: Icon(
                  Icons.person_2_outlined,
                  size: 100,
                  color: PrimaryBackGroundPurple,
                ),
              ),
              // Campo de Email o Username
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  DraftManager.saveLoginDraft({
                    'email': value,
                    'password': passwordController.text,
                  });
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    _validateInput(value.trim()); // Validamos el input
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: SecondaryPurple,
                  labelText: "Correo Electrónico o Usuario (@)",
                  prefixIcon: const Icon(Icons.account_circle_outlined),
                  border: const OutlineInputBorder(),
                  errorText: _emailError,
                  errorStyle: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de Contraseña
              TextField(
                controller: passwordController,
                obscureText: !showPassword,
                onChanged: (value) {
                  DraftManager.saveLoginDraft({
                    'email': emailController.text,
                    'password': value,
                  });
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    _validatePassword(value);
                  });
                },
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
                  errorText: _passwordError,
                  errorStyle: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de Inicio de Sesión
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

              const SizedBox(height: 20),

              // Botón para ir al Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No tienes cuenta?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Regístrate aquí",
                      style: TextStyle(
                        color: PrimaryBackGroundPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}