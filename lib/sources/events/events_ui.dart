import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

// Importaciones de tu proyecto
import 'package:bochinche_app/styles/NavBar.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/features/map/selector_ubicacion.dart';
import 'package:bochinche_app/sources/user_profile/user_profile_ui.dart';

// --- PANTALLA: EXPLORAR EVENTOS ---
class PublicEventsScreen extends StatefulWidget {
  const PublicEventsScreen({super.key});
  @override
  State<PublicEventsScreen> createState() => _PublicEventsScreenState();
}

class _PublicEventsScreenState extends State<PublicEventsScreen> {
  String selectedCategory = 'Todos';
  String searchQuery = '';
  List<String> selectedPreferences = ['Eventos'];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _fakeLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    SearchMode currentMode = SearchMode.eventos;
    if (selectedPreferences.contains('Eventos privados')) {
      currentMode = SearchMode.privados;
    }
    if (selectedPreferences.contains('Bochincheros')) {
      currentMode = SearchMode.bochincheros;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const BochincheAppBar(),
      drawer: const Navbar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(currentMode),
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const BochincheFilterLoader()
                : _buildResultsList(currentMode),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Explorar',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: PrimaryPurple,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                selectedCategory = 'Todos';
                searchQuery = '';
                _searchController.clear();
                selectedPreferences = ['Eventos'];
              });
              _fakeLoading();
            },
            icon: const Icon(Icons.filter_alt_off, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(SearchMode mode) {
    String hint = "Buscar eventos...";
    if (mode == SearchMode.bochincheros) hint = "Buscar bochincheros...";
    if (mode == SearchMode.privados) hint = "Ingresa código de acceso...";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, color: PrimaryPurple),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward, color: PrimaryPurple),
            onPressed: () {
              setState(() => searchQuery = _searchController.text.trim());
              _fakeLoading();
            },
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (val) {
          setState(() => searchQuery = val.trim());
          _fakeLoading();
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Categoría',
              border: InputBorder.none,
            ),
            items: [
              'Todos',
              'Concierto',
              'Teatro',
              'Fiesta',
              'Stand Up',
              'Otros',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) {
              setState(() => selectedCategory = val!);
              _fakeLoading();
            },
          ),
          const Divider(),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Eventos', 'Eventos privados', 'Bochincheros'].map((
                pref,
              ) {
                final isSelected = selectedPreferences.contains(pref);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      pref,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: PrimaryPurple,
                    checkmarkColor: Colors.white,
                    onSelected: (s) {
                      setState(() {
                        selectedPreferences.clear();
                        selectedPreferences.add(pref);
                      });
                      _fakeLoading();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(SearchMode mode) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chargeFilteredEvents(
        mode: mode,
        category: selectedCategory,
        search: searchQuery,
      ),
      builder: (context, snap) {
        if (!snap.hasData) return const BochincheFilterLoader();
        final items = snap.data!;
        if (items.isEmpty) {
          return const Center(child: Text("Sin resultados coincidentes"));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: PrimaryPurple.withValues(alpha: 0.1),
                  child: Icon(
                    mode == SearchMode.bochincheros
                        ? Icons.person
                        : Icons.celebration,
                    color: PrimaryPurple,
                  ),
                ),
                title: Text(
                  item['name'] ?? item['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${item['type'] ?? 'General'} • ${item['startDate'] ?? ''}",
                ),
                onTap: () {
                  if (mode == SearchMode.bochincheros) {
                    userToReport = item['uid'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const OrgProfile()),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

// --- PANTALLA: CREAR EVENTO ---
class EventosCreate extends StatelessWidget {
  const EventosCreate({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BochincheAppBar(),
      drawer: const Navbar(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Crea tu próximo Bochinche',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  color: PrimaryPurple,
                ),
              ),
            ),
            FormCreateEvent(),
          ],
        ),
      ),
    );
  }
}

class FormCreateEvent extends StatefulWidget {
  const FormCreateEvent({super.key});
  @override
  State<FormCreateEvent> createState() => _FormCreateEventState();
}

class _FormCreateEventState extends State<FormCreateEvent> {
  @override
  void initState() {
    super.initState();
    loadEventDraft().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Información General"),
          TextField(
            controller: nombreEventoController,
            decoration: _inputStyle("Nombre del Evento", Icons.title),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: descripcionController,
            maxLines: 3,
            decoration: _inputStyle(
              "Descripción del evento",
              Icons.description,
            ),
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            initialValue: selectedType,
            decoration: _inputStyle("Categoría", Icons.category),
            items: [
              'Concierto',
              'Teatro',
              'Fiesta',
              'Stand Up',
              'Otros',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() {
              selectedType = val;
              typeC = val;
            }),
          ),
          const SizedBox(height: 25),
          _sectionTitle("Ubicación y Aforo"),
          TextField(
            controller: direccionController,
            decoration: _inputStyle("Dirección física", Icons.pin_drop),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: aforoController,
            keyboardType: TextInputType.number,
            decoration: _inputStyle("Capacidad total", Icons.people),
          ),
          const SizedBox(height: 15),
          ListTile(
            tileColor: PrimaryPurple.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: PrimaryPurple.withValues(alpha: 0.2)),
            ),
            leading: const Icon(Icons.map, color: PrimaryPurple),
            title: Text(
              latitudC != 10.4806
                  ? "📍 Ubicación fijada correctamente"
                  : "Toca para ubicar en el mapa",
            ),
            onTap: () async {
              final LatLng? res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => const SelectorUbicacion(esSelector: true),
                ),
              );
              if (res != null) {
                setState(() {
                  latitudC = res.latitude;
                  longitudC = res.longitude;
                });
              }
            },
          ),
          const SizedBox(height: 25),
          _sectionTitle("Configuración de Acceso"),
          SwitchListTile(
            title: const Text(
              "Evento Privado",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Solo visible mediante código directo"),
            value: isPrivateC,
            activeThumbColor: PrimaryPurple,
            onChanged: (v) => setState(() => isPrivateC = v),
          ),
          SwitchListTile(
            title: const Text(
              "Evento de Pago",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Los bochincheros deben pagar entrada"),
            value: isPayedC,
            activeThumbColor: PrimaryPurple,
            onChanged: (v) => setState(() => isPayedC = v),
          ),
          if (isPayedC) ...[
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: _inputStyle("Precio (Bs)", Icons.monetization_on),
            ),
          ],
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PrimaryPurple,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
            ),
            onPressed: () => createEvent(context),
            child: const Text(
              "PUBLICAR BOCHINCHE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: PrimaryPurple),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

// --- PANTALLA: PANEL DE CONTROL ---
class ControlPanelEvent extends StatelessWidget {
  const ControlPanelEvent({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BochincheAppBar(),
      drawer: const Navbar(),
      body: const MyEvents(),
    );
  }
}

class MyEvents extends StatelessWidget {
  const MyEvents({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('id_organizer', isEqualTo: uid)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("Aún no has creado eventos."));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  data['name'] ?? 'Sin nombre',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${data['type']} • ${data['state']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => docs[i].reference.delete(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class BochincheFilterLoader extends StatelessWidget {
  const BochincheFilterLoader({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: PrimaryPurple),
        const SizedBox(height: 15),
        Text(
          getBochincheLoadingMessage(),
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}
