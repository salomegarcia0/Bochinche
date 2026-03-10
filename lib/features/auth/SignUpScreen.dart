import 'dart:async';
import 'package:bochinche_app/data/auth_service.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bochinche_app/core/utils/draft_manager.dart';

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
        tipoDocumento =
            (draft['docType'] != null && draft['docType']!.isNotEmpty)
            ? draft['docType']
            : null;
        cedulaController.text = draft['cedula'] ?? '';
        selectedPhonePrefix =
            (draft['phonePrefix'] != null && draft['phonePrefix']!.isNotEmpty)
            ? draft['phonePrefix']
            : null;
        phoneController.text = draft['phoneNum'] ?? '';
        passwordController.text = draft['password'] ?? '';
      });
    }
  }

  // --- PERSISTENCE HELPER ---
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

  // --- VALIDACIÓN ---
  Timer? _debounce;
  String? _emailError;
  String? _phoneError;
  String? _cedulaError;
  String? _passwordError;
  String? _nameError;
  String? _docTypeError;
  String? _phonePrefixError;
  // --- ESTADOS ---
  bool cargando = false;
  bool showPassword = false;
  String? tipoDocumento;
  String? selectedPhonePrefix;

  // Listas oficiales según tu lógica de negocio en Caracas
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
  void dispose() {
    _debounce?.cancel();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    cedulaController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE VALIDACIÓN ---
  void _onEmailChanged(String value) {
    _saveLocalDraft();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _validateEmail(value);
    });
  }

  void _validateEmail(String email) {
    final bool emailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);

    setState(() {
      if (email.isEmpty) {
        _emailError = "El correo es requerido";
      } else if (!emailValid) {
        _emailError = "El correo no es válido";
      } else {
        _emailError = null;
      }
    });
  }

  void _onPhoneChanged(String value) {
    _saveLocalDraft();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _validatePhone(value);
    });
  }

  void _validatePhone(String phone) {
    setState(() {
      if (phone.isEmpty) {
        _phoneError = "Campo Requerido";
      } else if (phone.length != 7) {
        _phoneError = "Debe tener 7 dígitos";
      } else {
        _phoneError = null;
      }
    });
  }

  void _onCedulaChanged(String value) {
    _saveLocalDraft();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _validateCedula(value);
    });
  }

  void _validateCedula(String cedula) {
    setState(() {
      if (cedula.isEmpty) {
        _cedulaError = "Campo requerido";
      } else if (cedula.length < 6) {
        _cedulaError = "Demasiado corta";
      } else {
        _cedulaError = null;
      }
    });
  }

  void _onPasswordChanged(String value) {
    _saveLocalDraft();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _validatePassword(value);
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

  void _onNameChanged(String value) {
    _saveLocalDraft();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _validateName(value);
    });
  }

  void _validateName(String name) {
    setState(() {
      if (name.trim().isEmpty) {
        _nameError = "El nombre es requerido";
      } else {
        _nameError = null;
      }
    });
  }

  bool _validateAll() {
    _validateName(nameController.text);
    _validateEmail(emailController.text);
    _validateCedula(cedulaController.text);
    _validatePhone(phoneController.text);
    _validatePassword(passwordController.text);

    setState(() {
      _docTypeError = tipoDocumento == null ? "Requerido" : null;
      _phonePrefixError = selectedPhonePrefix == null ? "Requerido" : null;
    });

    return _nameError == null &&
        _emailError == null &&
        _cedulaError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _docTypeError == null &&
        _phonePrefixError == null;
  }

  // --- LÓGICA DE REGISTRO ---
  void executeSignUp() async {
    if (!_validateAll()) {
      _showSnackBar(
        "Por favor, corrige los errores en el formulario",
        isError: true,
      );
      return;
    }

    setState(() => cargando = true);

    try {
      String letraDoc = tipoDocumento!.split(':')[0];
      String identificacionCompleta =
          "$letraDoc-${cedulaController.text.trim()}";
      String telefonoCompleto =
          "$selectedPhonePrefix${phoneController.text.trim()}";

      User? user = await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        rol: 'organizador',
        cedula: identificacionCompleta,
        phone: telefonoCompleto,
      );

      if (user != null && user.emailVerified == false && mounted) {
        DraftManager.clearSignUpDraft();
        _showSnackBar("Registro exitoso. Verifica tu correo para continuar.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
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
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
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
              "Crear Cuenta",
              style: TextStyle(
                color: SecondaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: PrimaryPurple,
            elevation: 0,
            iconTheme: const IconThemeData(color: SecondaryPurple),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20,
              ),
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
            Icon(
              Icons.person_add_alt_1_outlined,
              size: 80,
              color: PrimaryBackGroundPurple,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              onChanged: _onNameChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: SecondaryPurple,
                labelText: "Nombre Completo",
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(),
                errorText: _nameError,
                errorStyle: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              onChanged: _onEmailChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: SecondaryPurple,
                labelText: "Correo Electrónico",
                prefixIcon: const Icon(Icons.email_outlined),
                border: const OutlineInputBorder(),
                errorText: _emailError,
                errorStyle: const TextStyle(color: Colors.red),
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
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: SecondaryPurple,
                      labelText: "Tipo",
                      border: const OutlineInputBorder(),
                      errorText: _docTypeError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                    items: docTypes
                        .map(
                          (val) => DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (BuildContext context) {
                      return docTypes.map<Widget>((String item) {
                        return Text(
                          item.split(':')[0],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                    onChanged: (val) {
                      setState(() {
                        tipoDocumento = val;
                        _docTypeError = null;
                        _saveLocalDraft();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: cedulaController,
                    onChanged: _onCedulaChanged,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: SecondaryPurple,
                      labelText: "Cédula",
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: const OutlineInputBorder(),
                      counterText: "",
                      errorText: _cedulaError,
                      errorStyle: const TextStyle(color: Colors.red),
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
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: SecondaryPurple,
                      labelText: "Prefijo",
                      border: const OutlineInputBorder(),
                      errorText: _phonePrefixError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                    items: phonePrefixes
                        .map(
                          (val) => DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedPhonePrefix = val;
                        _phonePrefixError = null;
                        _saveLocalDraft();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: phoneController,
                    onChanged: _onPhoneChanged,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: SecondaryPurple,
                      labelText: "Número",
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: const OutlineInputBorder(),
                      counterText: "",
                      errorText: _phoneError,
                      errorStyle: const TextStyle(color: Colors.red),
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
              onChanged: _onPasswordChanged,
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
                  onPressed: () => setState(() => showPassword = !showPassword),
                ),
                border: const OutlineInputBorder(),
                errorText: _passwordError,
                errorStyle: const TextStyle(color: Colors.red),
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
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ),
                  child: const Text(
                    "Ingresa aquí",
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
    );
  }
}
