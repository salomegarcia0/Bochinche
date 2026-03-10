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
  UserModel? _usuario;
  bool _cargando = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // CAMBIO: Ahora son 3 pestañas (Por Realizar, Realizados, Privados)
    _tabController = TabController(length: 3, vsync: this);
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
            _usuario = UserModel.fromMap(
              doc.data() as Map<String, dynamic>,
              currentUser.uid,
            );
            _cargando = false;
          });
        }
      } catch (e) {
        debugPrint("Error al obtener datos: $e");
        if (mounted) setState(() => _cargando = false);
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

  // ----------------------------------------------------------------------
  // LÓGICA DE ESTADOS Y FECHAS
  // ----------------------------------------------------------------------

  DateTime _getFechaExacta(Map<String, dynamic> data) {
    try {
      String? fechaString = data['startDate'];
      DateTime fechaBase = fechaString != null
          ? DateTime.parse(fechaString)
          : DateTime.now();

      if (data['startTime'] != null && data['startTime'] is Map) {
        int hora = data['startTime']['hour'] ?? 0;
        int minuto = data['startTime']['minute'] ?? 0;
        return DateTime(
          fechaBase.year,
          fechaBase.month,
          fechaBase.day,
          hora,
          minuto,
        );
      }
      return fechaBase;
    } catch (e) {
      return DateTime.now();
    }
  }

  // Calcula si está Finalizado o Próximo según la hora actual
  String _calcularEstado(Map<String, dynamic> data) {
    DateTime inicio = _getFechaExacta(data);
    DateTime ahora = DateTime.now();

    if (ahora.isAfter(inicio)) {
      return "Finalizado";
    } else {
      return "Próximo";
    }
  }

  Color _colorEstado(String estado) {
    if (estado == "Finalizado") return Colors.grey;
    return const Color.fromARGB(255, 88, 24, 100); // Próximo
  }

  // ----------------------------------------------------------------------
  // MODAL DE DETALLES
  // ----------------------------------------------------------------------
  void _mostrarDetalleEvento(Map<String, dynamic> data) {
    // Calculamos estado al momento de abrir
    String estadoReal = _calcularEstado(data);
    Color colorEstado = _colorEstado(estadoReal);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Título
                  Text(
                    data['name'] ?? "Evento sin nombre",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: PrimaryPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Imagen grande
                  if (data['image_url'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        data['image_url'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Detalles
                  _infoRow(
                    Icons.description,
                    "Descripción",
                    data['description'] ?? "Sin descripción",
                  ),
                  _infoRow(
                    Icons.location_on,
                    "Ubicación",
                    data['address'] ?? "No especificada",
                  ),
                  _infoRow(
                    Icons.people,
                    "Aforo",
                    "${data['capacity'] ?? '?'} personas",
                  ),
                  _infoRow(
                    Icons.phone,
                    "Contacto",
                    data['contact'] ?? "No disponible",
                  ),
                  _infoRow(Icons.category, "Tipo", data['type'] ?? "General"),

                  // Estado del evento (CALCULADO)
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Estado: $estadoReal",
                      style: TextStyle(
                        color: colorEstado,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // FORMULARIO DE VERIFICACIÓN (TIPO INSTAGRAM/TWITTER/BINANCE)
  // ----------------------------------------------------------------------
  void _mostrarFormularioVerificacion(String uid) {
    final _formKey = GlobalKey<FormState>();
    final _domicilioCtrl = TextEditingController();
    final _edadCtrl = TextEditingController();
    final _justificacionCtrl = TextEditingController();
    final _cantidadEventosCtrl = TextEditingController();
    final _tiempoEventosCtrl = TextEditingController();

    String _sexoSeleccionado = 'Prefiero no decirlo';
    bool _enviando = false;

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
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                      const Text(
                        "Completa estos datos para evaluar tu perfil como organizador de eventos.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // 2. Domicilio Fiscal
                      TextFormField(
                        controller: _domicilioCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Domicilio Fiscal',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),

                      // 3. Edad y Sexo
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _edadCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Edad',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _sexoSeleccionado,
                              decoration: const InputDecoration(
                                labelText: 'Sexo',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  [
                                        'Masculino',
                                        'Femenino',
                                        'Otro',
                                        'Prefiero no decirlo',
                                      ]
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) =>
                                  setModalState(() => _sexoSeleccionado = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 4. Experiencia
                      const Text(
                        "Experiencia haciendo eventos",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cantidadEventosCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Cantidad aprox.',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _tiempoEventosCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Tiempo (ej. 2 años)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 5. Justificación
                      TextFormField(
                        controller: _justificacionCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText:
                              '¿Por qué deberíamos darte la verificación?',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 20),

                      // Botón Enviar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SecondaryPurple,
                          ),
                          onPressed: _enviando
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setModalState(() => _enviando = true);
                                    try {
                                      Map<String, dynamic> formData = {
                                        'domicilio_fiscal': _domicilioCtrl.text
                                            .trim(),
                                        'edad':
                                            int.tryParse(
                                              _edadCtrl.text.trim(),
                                            ) ??
                                            0,
                                        'sexo': _sexoSeleccionado,
                                        'experiencia_cantidad':
                                            int.tryParse(
                                              _cantidadEventosCtrl.text.trim(),
                                            ) ??
                                            0,
                                        'experiencia_tiempo': _tiempoEventosCtrl
                                            .text
                                            .trim(),
                                        'justificacion': _justificacionCtrl.text
                                            .trim(),
                                        'fecha_solicitud':
                                            FieldValue.serverTimestamp(),
                                      };

                                      await AuthService().solicitarVerificacion(
                                        uid,
                                        formData,
                                      );

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Solicitud enviada para revisión",
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setModalState(() => _enviando = false);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: _enviando
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Enviar Solicitud",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: SecondaryPurple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
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
                tooltip: "Cerrar Sesión",
              ),
            ],
          ),
          body: _cargando
              ? const Center(
                  child: CircularProgressIndicator(color: SecondaryPurple),
                )
              : _usuario == null
              ? const Center(child: Text("Error al cargar perfil"))
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    // --- FOTO Y NOMBRE ---
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: SecondaryPurple,
                      backgroundImage: _usuario!.profileImageUrl != null
                          ? NetworkImage(_usuario!.profileImageUrl!)
                          : null,
                      child: _usuario!.profileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: PrimaryPurple,
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    // --- SISTEMA DE VERIFICACIÓN EN CASCADA (ID -> INSIGNIA) ---
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(_usuario!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        
                        var data = snapshot.data!.data() as Map<String, dynamic>;
                        
                        // Estados de Cédula
                        String idState = data['idProcessState'] ?? 'none'; 
                        
                        // Estados de Insignia Azul
                        String vStatus = data['verificationStatus'] ?? 'unverified';

                        return Column(
                          children: [
                            // 1. NOMBRE Y CHECK AZUL (Solo si ya es 'verified')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _usuario!.nombre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (vStatus == 'verified') ...[
                                  const SizedBox(width: 5),
                                  const Icon(Icons.verified, color: Colors.blue, size: 24),
                                ],
                              ],
                            ),
                            const SizedBox(height: 15),

                            // 2. SECCIÓN CÉDULA (Solo se muestra si no está aprobada ni en espera)
                            if (vStatus != 'verified' && idState == 'none')
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const Authetication_steps()),
                                    );
                                  },
                                  icon: const Icon(Icons.badge_outlined, color: Colors.orange),
                                  label: const Text("Verificar Cédula (ID)", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.orange, width: 2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              )
                            else if (idState == 'waiting' && vStatus != 'verified')
                              const Padding(
                                padding: EdgeInsets.only(bottom: 15),
                                child: Text("Cédula en revisión ⏳", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                              ),

                            // 3. SECCIÓN INSIGNIA (Solo se habilita si la Cédula ya es 'approved')
                            if (idState == 'approved') ...[
                              if (vStatus == 'unverified')
                                ElevatedButton.icon(
                                  onPressed: () => _mostrarFormularioVerificacion(_usuario!.uid),
                                  icon: const Icon(Icons.verified_user, size: 16, color: Colors.white),
                                  label: const Text("Solicitar Insignia Oficial", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                )
                              else if (vStatus == 'pending')
                                const Text(
                                  "Solicitud de Insignia en revisión ⏳",
                                  style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                            ] else if (vStatus != 'verified') ...[
                              // Mensaje informativo opcional mientras no esté aprobada la ID
                              const Text(
                                "Debes validar tu ID para solicitar la insignia oficial",
                                style: TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            ],
                            
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),

                    // --- BOTÓN EDITAR ---
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_usuario != null) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfileScreen(usuario: _usuario!),
                            ),
                          );
                          if (result == true) _cargarUsuario();
                        }
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

                    // --- PESTAÑAS (3 TABS) ---
                    TabBar(
                      controller: _tabController,
                      labelColor: SecondaryPurple,
                      unselectedLabelColor: Colors.white60,
                      indicatorColor: SecondaryPurple,
                      tabs: const [
                        Tab(text: "Por Realizar"),
                        Tab(text: "Realizados"),
                        Tab(text: "Privados"),
                      ],
                    ),

                    // --- LISTAS ---
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildEventList("proximos"),
                          _buildEventList("pasados"),
                          _buildEventList("privados"),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------------
  // CONSTRUCCIÓN DE LA LISTA INTELIGENTE
  // ----------------------------------------------------------------------
  Widget _buildEventList(String tipo) {
    if (_usuario == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('id_organizer', isEqualTo: _usuario!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No has creado eventos",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        // --- FILTRADO EN EL CLIENTE ---
        final eventosFiltrados = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          DateTime fechaEvento = _getFechaExacta(data);
          DateTime ahora = DateTime.now();
          bool esPrivado = data['isPrivate'] ?? false;

          // Lógica de Pestañas:
          if (tipo == "privados") {
            // Pestaña Privados: SOLO muestra privados (futuros o pasados)
            return esPrivado;
          } else {
            // Pestañas Públicas: NO mostrar privados
            if (esPrivado) return false;

            // Filtro de tiempo para públicos
            if (tipo == "proximos") {
              return fechaEvento.isAfter(ahora);
            } else if (tipo == "pasados") {
              return fechaEvento.isBefore(ahora);
            }
          }
          return false;
        }).toList();

        // --- ORDENAMIENTO ---
        eventosFiltrados.sort((a, b) {
          DateTime fechaA = _getFechaExacta(a.data() as Map<String, dynamic>);
          DateTime fechaB = _getFechaExacta(b.data() as Map<String, dynamic>);

          if (tipo == "proximos") {
            return fechaA.compareTo(fechaB); // Ascendente (más cercano primero)
          } else {
            return fechaB.compareTo(
              fechaA,
            ); // Descendente (más reciente primero)
          }
        });

        if (eventosFiltrados.isEmpty) {
          return const Center(
            child: Text(
              "Sin eventos en esta lista",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          itemCount: eventosFiltrados.length,
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, index) {
            final doc = eventosFiltrados[index];
            final data = doc.data() as Map<String, dynamic>;
            final String? imagenUrl = data['image_url'];

            DateTime fechaExacta = _getFechaExacta(data);
            String fechaTexto =
                "${fechaExacta.day}/${fechaExacta.month}/${fechaExacta.year}";
            String horaTexto =
                "${fechaExacta.hour}:${fechaExacta.minute.toString().padLeft(2, '0')}";

            // Estado visual calculado
            String estadoReal = _calcularEstado(data);
            Color colorEstado = _colorEstado(estadoReal);
            bool esPrivado = data['isPrivate'] ?? false;

            return Card(
              color: Colors.white.withOpacity(0.95),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                onTap: () => _mostrarDetalleEvento(data),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imagenUrl != null && imagenUrl.isNotEmpty
                      ? Image.network(
                          imagenUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: PrimaryPurple,
                          child: Icon(
                            esPrivado ? Icons.lock : Icons.event,
                            color: Colors.white,
                          ),
                        ),
                ),
                title: Text(
                  data['name'] ?? "Evento sin nombre",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$fechaTexto - $horaTexto",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Row(
                      children: [
                        Text(
                          "Estado: $estadoReal",
                          style: TextStyle(
                            color: colorEstado,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (data['type'] == 'Privado')
                          const Text(
                            "• PRIVADO",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
