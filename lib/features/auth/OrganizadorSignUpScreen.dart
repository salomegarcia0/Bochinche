import 'package:bochinche_app/data/auth_service.dart';
import 'package:bochinche_app/features/map/mapa.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class OrganizadorSignUpScreen extends StatefulWidget {
  const OrganizadorSignUpScreen({super.key});

  @override
  State<OrganizadorSignUpScreen> createState() =>
      _OrganizadorSignUpScreenState();
}

class _OrganizadorSignUpScreenState extends State<OrganizadorSignUpScreen> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController businessEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rifNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final AuthService _authService = AuthService();
  bool cargando = false;
  bool showPassword = false;

  // Variable para manejar la selección de tipo de documento
  String tipoRif = 'J';

  void executeBusinessSignUp() async {
    if (companyNameController.text.isEmpty ||
        businessEmailController.text.isEmpty ||
        rifNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, rellena los datos de la empresa"),
        ),
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
      // Concatenamos el tipo de RIF con el número
      String rifCompleto = "$tipoRif-${rifNumberController.text.trim()}";

      User? user = await _authService.signUp(
        email: businessEmailController.text.trim(),
        password: passwordController.text.trim(),
        name: companyNameController.text.trim(),
        rol: 'organizador', // Rol fijo para esta pantalla
        rif: rifCompleto, // RIF completo
        phone: phoneController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Mapa()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error de Empresa: $error"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted)
        setState(() {
          cargando = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Organizador"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: companyNameController,
                decoration: const InputDecoration(
                  labelText: "Nombre de la Empresa / Organización",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: businessEmailController,
                decoration: const InputDecoration(
                  labelText: "Correo Electrónico",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              // Campo de RIF
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: tipoRif,
                      underline: const SizedBox(),
                      onChanged: (String? nuevo) =>
                          setState(() => tipoRif = nuevo!),
                      items: const [
                        DropdownMenuItem(value: 'J', child: Text('J')),
                        DropdownMenuItem(value: 'G', child: Text('G')),
                        DropdownMenuItem(value: 'V', child: Text('V')),
                        DropdownMenuItem(value: 'E', child: Text('E')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: rifNumberController,
                      decoration: const InputDecoration(
                        labelText: "Número de RIF",
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Teléfono de Contacto",
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
              const SizedBox(height: 30),

              cargando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: executeBusinessSignUp,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("REGISTRAR"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
