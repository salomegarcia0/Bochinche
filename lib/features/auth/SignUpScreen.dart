import 'package:bochinche_app/data/auth_service.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/authentication/authentication_steps.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- CONTROLLERS ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final AuthService _authService = AuthService();
  
  // --- ESTADOS ---
  bool cargando = false;
  bool showPassword = false;
  String? tipoDocumento; 
  String? selectedPhonePrefix;

  // Listas oficiales según tu lógica de negocio en Caracas
  final List<String> docTypes = ['V: Venezolano', 'E: Extranjero', 'P: Pasaporte', 'J: Jurídico', 'C: Comuna', 'G: Gubernamental', 'R: Firma Personal'];
  
  final List<String> phonePrefixes = ['0412', '0414', '0416', '0424', '0426'];

  // --- LÓGICA DE REGISTRO ---
  void executeSignUp() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        cedulaController.text.isEmpty ||
        phoneController.text.isEmpty ||
        tipoDocumento == null ||
        selectedPhonePrefix == null) {
      _showSnackBar("Por favor, rellena todos los campos y selecciones");
      return;
    }

    if (passwordController.text.length < 6) {
      _showSnackBar("La contraseña debe tener al menos 6 caracteres");
      return;
    }

    if (phoneController.text.trim().length != 7) {
      _showSnackBar("El número debe tener 7 dígitos después del prefijo");
      return;
    }

    setState(() => cargando = true);

    try {
      String letraDoc = tipoDocumento!.split(':')[0];
      String identificacionCompleta = "$letraDoc-${cedulaController.text.trim()}";
      String telefonoCompleto = "$selectedPhonePrefix${phoneController.text.trim()}";

      User? user = await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        rol: 'organizador',
        cedula: identificacionCompleta,
        phone: telefonoCompleto,
      );

      if (user != null && user.emailVerified == false && mounted) {
        _showSnackBar("Registro exitoso. Verifica tu correo para continuar.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Authetication_steps()),
        );
      }
    } catch (error) {
      if (mounted) _showSnackBar("Error: $error", isError: true);
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color.fromARGB(255, 239, 233, 240)),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: const Text(
              "Crear Cuenta",
              style: TextStyle(color: SecondaryPurple, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: PrimaryPurple,
            elevation: 0,
            iconTheme: const IconThemeData(color: SecondaryPurple),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
              child: SingleChildScrollView(child: contenidoPrincipal(context)),
            ),
          ),
        ),
      ],
    );
  }

  Widget contenidoPrincipal(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AccentPurple,
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.person_add_alt_1_outlined, size: 80, color: PrimaryBackGroundPurple),
            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: SecondaryPurple,
                labelText: "Nombre Completo / Razón Social",
                prefixIcon: Icon(Icons.person_outline),
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
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),

            // --- SECCIÓN: IDENTIFICACIÓN ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: tipoDocumento,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: SecondaryPurple,
                      labelText: "Tipo", // Ahora sí se verá igual a los demás
                      border: OutlineInputBorder(),
                    ),
                    items: docTypes.map((val) => DropdownMenuItem(
                      value: val, 
                      child: Text(val, style: const TextStyle(fontWeight: FontWeight.bold))
                    )).toList(),
                    selectedItemBuilder: (BuildContext context) {
  return docTypes.map<Widget>((String item) {
    // Esto es lo que se verá en la cajita cuando esté CERRADA
    return Text(item.split(':')[0], style: const TextStyle(fontWeight: FontWeight.bold));
  }).toList();
},
                    onChanged: (val) => setState(() => tipoDocumento = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: cedulaController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: SecondaryPurple,
                      labelText: "Número de Identificación",
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                      counterText: "",
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // --- SECCIÓN: TELÉFONO ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedPhonePrefix,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: SecondaryPurple,
                      labelText: "Prefijo",
                      border: OutlineInputBorder(),
                    ),
                    items: phonePrefixes.map((val) => DropdownMenuItem(
                      value: val, 
                      child: Text(val, style: const TextStyle(fontWeight: FontWeight.bold))
                    )).toList(),
                    onChanged: (val) => setState(() => selectedPhonePrefix = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: SecondaryPurple,
                      labelText: "Número",
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                      counterText: "",
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 7,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
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
                  icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => showPassword = !showPassword),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),

            cargando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: executeSignUp,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: PrimaryBackGroundPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("CREAR CUENTA"),
                  ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("¿Ya tienes cuenta?"),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => const LoginScreen()),
                  ),
                  child: const Text("Ingresa aquí", style: TextStyle(color: PrimaryBackGroundPurple, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
