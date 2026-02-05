import 'package:bochinche_app/data/auth_service.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/auth/OrganizadorSignUpScreen.dart';
import 'package:bochinche_app/features/map/Paginna_Inicio.dart';
import 'package:bochinche_app/features/map/mapa.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController extraDataController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final AuthService _authService = AuthService();
  bool cargando = false;
  bool showPassword = false;

  // Variable para manejar la selección de tipo de documento
  String tipoDocumento = 'V';

  void executeSignUp() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        extraDataController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, rellena todos los campos")),
      );
      return;
    }

    String password = passwordController.text;

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La contraseña debe tener al menos 6 caracteres")),
      );
      return;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La contraseña debe incluir al menos un número")),
      );
      return;
    }

    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La contraseña debe incluir un carácter especial (ej: @, #, *)")),
      );
      return;
    }

    if (phoneController.text.trim().length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El número telefónico debe tener 11 dígitos"),
        ),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      // Concatenamos el tipo de documento con el número
      String identificacionCompleta =
          "$tipoDocumento-${extraDataController.text.trim()}";

      User? user = await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        rol: 'usuario', // Rol fijo para esta pantalla
        cedula: identificacionCompleta,
        phone: phoneController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Pagina_Principal()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Bochinchero")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre Completo",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Correo Electrónico",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              // CAMPO  (V, E, P)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: tipoDocumento,
                      underline: const SizedBox(),
                      onChanged: (String? nuevoValor) {
                        setState(() {
                          tipoDocumento = nuevoValor!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 'V', child: Text('V')),
                        DropdownMenuItem(value: 'E', child: Text('E')),
                        DropdownMenuItem(value: 'P', child: Text('P')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: extraDataController,
                      decoration: const InputDecoration(
                        labelText: "Número de Identidad",
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
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
              const SizedBox(height: 25),

              cargando
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: executeSignUp,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("CREAR MI CUENTA"),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            // Navegar a la pantalla de registro de organizador
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const OrganizadorSignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "¿Eres organizador? Crea cuenta de empresa aquí",
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navegar a la pantalla de registro de organizador
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text("¿Tienes cuenta? Ingresa por aqui"),
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
