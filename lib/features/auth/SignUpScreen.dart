import 'package:bochinche_app/data/auth_service.dart';
import 'package:bochinche_app/features/map/Paginna_Inicio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:bochinche_app/styles/Color.dart';

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
        const SnackBar(
          content: Text("La contraseña debe tener al menos 6 caracteres"),
        ),
      );
      return;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La contraseña debe incluir al menos un número"),
        ),
      );
      return;
    }

    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La contraseña debe incluir un carácter especial (ej: @, #, *)",
          ),
        ),
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
    return Stack(
      children: [
        //fondo
        Container(color: PrimaryBackGroundPurple),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: const Text(
              "Registro",
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 20, 10, 0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: contenido(context),
              ),
            ),
          ),
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
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                //Se va a cambiar por el logo de la app
                child: Icon(
                  Icons.person_2_outlined,
                  size: 80,
                  color: PrimaryBackGroundPurple,
                ),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: SecondaryPurple,
                  labelText: "Nombre Completo",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: SecondaryPurple,
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
                      border: Border.all(color: PrimaryPurple),
                      color: SecondaryPurple,
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
                        filled: true,
                        fillColor: SecondaryPurple,
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
                  filled: true,
                  fillColor: SecondaryPurple,
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
              const SizedBox(height: 25),

              cargando
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: executeSignUp,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: PrimaryBackGroundPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("CREAR MI CUENTA"),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text("¿Eres organizador?"),
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
                                "Crea cuenta de empresa aquí",
                                style: TextStyle(
                                  color: PrimaryBackGroundPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text("¿Tienes cuenta?"),
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
                                "Ingresa por aqui",
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
            ],
          ),
        ),
      ),
    );
  }
}
