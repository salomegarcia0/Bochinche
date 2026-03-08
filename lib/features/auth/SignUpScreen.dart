import 'dart:async';
import 'package:bochinche_app/data/auth_service.dart';
import 'package:bochinche_app/features/authentication/authentication_steps.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bochinche_app/core/utils/draft_manager.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final AuthService _authService = AuthService();

  Timer? _debounce;
  String? _emailError,
      _phoneError,
      _cedulaError,
      _passwordError,
      _nameError,
      _docTypeError,
      _phonePrefixError;
  bool cargando = false;
  bool showPassword = false;
  String? tipoDocumento;
  String? selectedPhonePrefix;

  final List<String> docTypes = [
    'V: Venezolano',
    'E: Extranjero',
    'P: Pasaporte',
    'J: Jurídico',
    'C: Comuna',
    'G: Gubernamental',
    'R: Firma Personal',
  ];
  final List<String> phonePrefixes = ['0412', '0414', '0416', '0424', '0426'];

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final draft = await DraftManager.loadSignUpDraft();
    if (mounted && draft != null) {
      setState(() {
        nameController.text = draft['name'] ?? '';
        emailController.text = draft['email'] ?? '';
        tipoDocumento = draft['docType'];
        cedulaController.text = draft['cedula'] ?? '';
        selectedPhonePrefix = draft['phonePrefix'];
        phoneController.text = draft['phoneNum'] ?? '';
        passwordController.text = draft['password'] ?? '';
      });
    }
  }

  void _saveLocalDraft() {
    DraftManager.saveSignUpDraft({
      'name': nameController.text,
      'email': emailController.text,
      'docType': tipoDocumento,
      'cedula': cedulaController.text,
      'phonePrefix': selectedPhonePrefix,
      'phoneNum': phoneController.text,
      'password': passwordController.text,
    });
  }

  // --- VALIDACIONES (Lógica Javier) ---
  void _validateAll() {
    setState(() {
      _nameError = nameController.text.trim().isEmpty ? "Requerido" : null;
      _emailError =
          !RegExp(
            r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
          ).hasMatch(emailController.text)
          ? "Email inválido"
          : null;
      _cedulaError = cedulaController.text.length < 6
          ? "Cédula inválida"
          : null;
      _phoneError = phoneController.text.length != 7
          ? "Debe tener 7 dígitos"
          : null;
      _passwordError = passwordController.text.length < 6
          ? "Mínimo 6 caracteres"
          : null;
      _docTypeError = tipoDocumento == null ? "Requerido" : null;
      _phonePrefixError = selectedPhonePrefix == null ? "Requerido" : null;
    });
  }

  void executeSignUp() async {
    _validateAll();
    if (_nameError != null ||
        _emailError != null ||
        _cedulaError != null ||
        _phoneError != null ||
        _passwordError != null ||
        _docTypeError != null ||
        _phonePrefixError != null) {
      return;
    }

    setState(() => cargando = true);
    try {
      String letraDoc = tipoDocumento!.split(':')[0];
      User? user = await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        rol: 'organizador',
        cedula: "$letraDoc-${cedulaController.text.trim()}",
        phone: "$selectedPhonePrefix${phoneController.text.trim()}",
      );

      if (user != null && mounted) {
        DraftManager.clearSignUpDraft();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Authetication_steps()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 233, 240),
      appBar: AppBar(
        title: const Text(
          "Crear Cuenta",
          style: TextStyle(color: SecondaryPurple, fontWeight: FontWeight.bold),
        ),
        backgroundColor: PrimaryPurple,
        iconTheme: const IconThemeData(color: SecondaryPurple),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: AccentPurple,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.person_add,
                size: 70,
                color: PrimaryBackGroundPurple,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                onChanged: (v) {
                  _saveLocalDraft();
                },
                decoration: InputDecoration(
                  labelText: "Nombre Completo",
                  errorText: _nameError,
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                onChanged: (v) {
                  _saveLocalDraft();
                },
                decoration: InputDecoration(
                  labelText: "Correo Electrónico",
                  errorText: _emailError,
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: tipoDocumento,
                      hint: const Text("Tipo"),
                      items: docTypes
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.split(':')[0]),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() => tipoDocumento = v);
                        _saveLocalDraft();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: cedulaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Cédula",
                        errorText: _cedulaError,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedPhonePrefix,
                      hint: const Text("04xx"),
                      items: phonePrefixes
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() => selectedPhonePrefix = v);
                        _saveLocalDraft();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      maxLength: 7,
                      decoration: InputDecoration(
                        labelText: "Número",
                        errorText: _phoneError,
                        counterText: "",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  errorText: _passwordError,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => showPassword = !showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              cargando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: executeSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PrimaryBackGroundPurple,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "REGISTRARSE",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
