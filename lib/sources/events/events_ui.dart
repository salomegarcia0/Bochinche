import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:bochinche_app/styles/NavBar.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/features/map/selector_ubicacion.dart';
import 'package:bochinche_app/sources/user_profile/user_profile_ui.dart';

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
    await Future.delayed(const Duration(milliseconds: 800));
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: mode == SearchMode.bochincheros
              ? 'Buscar bochincheros...'
              : 'Buscar eventos...',
          prefixIcon: const Icon(Icons.search, color: PrimaryPurple),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (val) {
          setState(() => searchQuery = val);
          _fakeLoading();
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            underline: Container(),
            items: [
              'Todos',
              'Concierto',
              'Teatro',
              'Fiesta',
              'Stand Up',
              'Otros',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() {
              selectedCategory = val!;
              _fakeLoading();
            }),
          ),
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
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: PrimaryPurple,
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
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    mode == SearchMode.bochincheros
                        ? Icons.person
                        : Icons.event,
                  ),
                ),
                title: Text(item['name'] ?? item['nombre'] ?? 'Sin nombre'),
                subtitle: Text(item['type'] ?? 'Bochinchero'),
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

class EventosCreate extends StatelessWidget {
  const EventosCreate({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BochincheAppBar(),
      drawer: const Navbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Crea tu próximo Bochinche',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
              ),
            ),
            const FormCreateEvent(),
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: nombreEventoController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: selectedType,
            decoration: const InputDecoration(
              labelText: 'Categoría',
              border: OutlineInputBorder(),
            ),
            items: [
              'Concierto',
              'Teatro',
              'Fiesta',
              'Otros',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() {
              selectedType = val;
              typeC = val;
            }),
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.purple[50],
            leading: const Icon(Icons.map, color: PrimaryPurple),
            title: Text(
              latitudC != 10.4806
                  ? "Ubicación fijada"
                  : "Toca para ubicar en mapa",
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
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PrimaryPurple,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () => createEvent(context),
            child: const Text(
              'PUBLICAR EVENTO',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where(
            'id_organizer',
            isEqualTo: FirebaseAuth.instance.currentUser?.uid,
          )
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(d['name'] ?? 'Evento'),
                subtitle: Text(d['type'] ?? 'General'),
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
