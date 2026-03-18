import 'package:bochinche_app/data/user_model.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/profile/edit_profile_screen.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bochinche_app/data/auth_service.dart';
import 'package:bochinche_app/features/authentication/authentication_steps.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  UserModel? usuario;
  bool cargando = true;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    // Javier: Inicializamos el controlador para 3 pestañas
    tabController = TabController(length: 3, vsync: this);
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (doc.exists) {
          setState(() {
            usuario = UserModel.fromMap(
              doc.data() as Map<String, dynamic>,
              currentUser.uid,
            );
            cargando = false;
          });
        }
      } catch (e) {
        debugPrint("Error al obtener datos: $e");
        if (mounted) setState(() => cargando = false);
      }
    }
  }

  void _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _mostrarFormularioVerificacion(String uid) {
    final formKey = GlobalKey<FormState>();
    final justificacionCtrl = TextEditingController();
    bool enviando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Solicitud de Verificación",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: PrimaryPurple,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: justificacionCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: '¿Por qué quieres la insignia?',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SecondaryPurple,
                          ),
                          onPressed: enviando
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    setModalState(() => enviando = true);
                                    try {
                                      await AuthService().solicitarVerificacion(
                                        uid,
                                        {
                                          'justificacion':
                                              justificacionCtrl.text,
                                        },
                                      );
                                      if (context.mounted)
                                        Navigator.pop(context);
                                    } catch (e) {
                                      setModalState(() => enviando = false);
                                    }
                                  }
                                },
                          child: enviando
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Enviar Solicitud",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: PrimaryBackGroundPurple),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              "Mi Perfil",
              style: TextStyle(
                color: SecondaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: PrimaryPurple,
            centerTitle: true,
            elevation: 0,
            iconTheme: const IconThemeData(color: SecondaryPurple),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _cerrarSesion,
              ),
            ],
          ),
          body: cargando
              ? const Center(
                  child: CircularProgressIndicator(color: SecondaryPurple),
                )
              : usuario == null
              ? const Center(child: Text("Error al cargar perfil"))
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: SecondaryPurple,
                      backgroundImage: usuario!.profileImageUrl != null
                          ? NetworkImage(usuario!.profileImageUrl!)
                          : null,
                      child: usuario!.profileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: PrimaryPurple,
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),

                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(usuario!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        var data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        String idState = data['idProcessState'] ?? 'none';
                        String vStatus =
                            data['verificationStatus'] ?? 'unverified';
                        bool isPremium = data['isPremium'] ?? false;
                        String planType = data['planType'] ?? 'Gold';

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  usuario!.nombre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (vStatus == 'verified') ...[
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 10),
                            if (!isPremium)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/premium'),
                                  icon: const Icon(
                                    Icons.stars,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "¡HAZTE PREMIUM!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    planType.contains("DIAMOND")
                                        ? Icons.diamond
                                        : Icons.workspace_premium,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Socio Premium $planType",
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 15),

                            if (vStatus != 'verified' && idState == 'none')
                              OutlinedButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const Authetication_steps(),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.badge_outlined,
                                  color: Colors.orange,
                                ),
                                label: const Text(
                                  "Verificar Cédula (ID)",
                                  style: TextStyle(color: Colors.orange),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.orange),
                                ),
                              ),

                            if (idState == 'approved' &&
                                vStatus == 'unverified')
                              ElevatedButton.icon(
                                onPressed: () => _mostrarFormularioVerificacion(
                                  usuario!.uid,
                                ),
                                icon: const Icon(
                                  Icons.verified_user,
                                  color: Colors.white,
                                ),
                                label: const Text("Solicitar Insignia Oficial"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),

                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),

                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProfileScreen(usuario: usuario!),
                          ),
                        );
                        if (result == true) _cargarUsuario();
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: PrimaryPurple,
                      ),
                      label: const Text(
                        "Editar Perfil",
                        style: TextStyle(color: PrimaryPurple),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SecondaryPurple,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // JAVIER: Títulos de las pestañas
                    TabBar(
                      controller: tabController,
                      labelColor: SecondaryPurple,
                      unselectedLabelColor: Colors.white60,
                      indicatorColor: SecondaryPurple,
                      tabs: const [
                        Tab(text: "Por Realizar"),
                        Tab(text: "Realizados"),
                        Tab(text: "Privados"),
                      ],
                    ),

                    // JAVIER: Contenido de las pestañas (CORREGIDO AQUÍ)
                    Expanded(
                      child: TabBarView(
                        controller:
                            tabController, // <--- ESTA ES LA LÍNEA QUE FALTABA
                        children: const [
                          Center(
                            child: Text(
                              "Eventos Próximos",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Center(
                            child: Text(
                              "Eventos Pasados",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Center(
                            child: Text(
                              "Eventos Privados",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
