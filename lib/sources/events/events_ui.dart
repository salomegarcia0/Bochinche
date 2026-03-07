<<<<<<< Updated upstream
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

// --- CORRECCIÓN DE RUTAS ---
// Usamos 'package:' que es la forma más segura en Flutter para evitar errores de ruta
import 'package:bochinche_app/sources/events_logic.dart';
import 'package:bochinche_app/features/map/mapa.dart';

class EventosCreate extends StatelessWidget {
  const EventosCreate({super.key});
=======
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:bochinche_app/features/map/BuscadorEventoMapa.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/styles/NavBar.dart';

// --- PANTALLA: EXPLORAR EVENTOS ---
class PublicEventsScreen extends StatefulWidget {
  const PublicEventsScreen({super.key});
  @override
  State<PublicEventsScreen> createState() => _PublicEventsScreenState();
}

class _PublicEventsScreenState extends State<PublicEventsScreen> {
  String category = 'Todos';
  String query = '';
  final TextEditingController _con = TextEditingController();
>>>>>>> Stashed changes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< Updated upstream
      appBar: AppBar(title: const Text("Bochinche - Crear Evento")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Card(
              color: Colors.white,
              elevation: 4,
              margin: EdgeInsets.all(23),
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Crea tus eventos y promociónalos al mundo',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ControlPanelEvent(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Panel de control'),
                ),
              ],
            ),
            const Divider(),
            const FormCreateEvent(),
=======
      appBar: const BochincheAppBar(),
      drawer: const Navbar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _con,
                  onChanged: (v) => setState(() => query = v),
                  decoration: const InputDecoration(
                    hintText: "Buscar por nombre o ID...",
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Categoría",
                          border: OutlineInputBorder(),
                        ),
                        // FIX: Se usa initialValue para asegurar la consistencia del estado inicial
                        initialValue: category,
                        items:
                            [
                                  'Todos',
                                  'Concierto',
                                  'Teatro',
                                  'Cine',
                                  'Restaurante',
                                  'Stand Up',
                                  'Fiesta',
                                  'Conferencia',
                                  'Otros',
                                ]
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => category = v!),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_alt_off, color: Colors.red),
                      onPressed: () => setState(() {
                        category = 'Todos';
                        query = '';
                        _con.clear();
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: chargeFilteredEvents(category: category, search: query),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snap.data!;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final d = items[i];
                    final cat = getCategoryData(d['type']);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cat['color'],
                          child: Icon(
                            cat['icon'],
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          d['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("${d['type']} • ID: ${d['id']}"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- PANTALLA: CREAR EVENTO ---
class EventosCreate extends StatefulWidget {
  const EventosCreate({super.key});
  @override
  State<EventosCreate> createState() => _EventosCreateState();
}

class _EventosCreateState extends State<EventosCreate> {
  LatLng? p;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BochincheAppBar(),
      drawer: const Navbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nombreEventoController,
              decoration: const InputDecoration(labelText: 'Nombre del Evento'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              // FIX: Agregado initialValue si selectedType tiene un valor por defecto
              initialValue: selectedType,
              items: [
                'Concierto',
                'Teatro',
                'Cine',
                'Restaurante',
                'Stand Up',
                'Fiesta',
                'Conferencia',
                'Otros',
              ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => selectedType = v),
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
            TextField(
              controller: aforoController,
              decoration: const InputDecoration(labelText: 'Aforo'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 2,
            ),
            SwitchListTile(
              title: const Text("¿Es un evento de pago?"),
              value: isPayed,
              onChanged: (v) => setState(() => isPayed = v),
            ),
            if (isPayed)
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio de entrada',
                ),
              ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: Colors.purple[50],
              leading: const Icon(Icons.map, color: Colors.purple),
              title: Text(
                p == null ? "Ubicar en Mapa" : "Ubicación fijada correctamente",
              ),
              onTap: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const BuscadorEventoMapa(esSelector: true),
                  ),
                );
                // FIX: Llaves añadidas para mayor seguridad y claridad
                if (res != null) {
                  setState(() {
                    p = res;
                    latitudC = res.latitude;
                    longitudC = res.longitude;
                  });
                }
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => createEvent(context),
                child: const Text("PUBLICAR BOCHINCHE"),
              ),
            ),
>>>>>>> Stashed changes
          ],
        ),
      ),
    );
  }
}

<<<<<<< Updated upstream
class FormCreateEvent extends StatefulWidget {
  const FormCreateEvent({super.key});

  @override
  State<FormCreateEvent> createState() => _FormCreateEventState();
}

class _FormCreateEventState extends State<FormCreateEvent> {
  String? selectedValue;
  LatLng? ubicacionTemporal;
  TimeOfDay hora1 = TimeOfDay.now();

  final List<String> options = [
    'Concierto',
    'Conferencias',
    'Stand Up',
    'Teatro',
    'Fiestas',
    'Cine',
    'Restaurante',
    'Otros',
  ];

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    bool isStart,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toString().split(" ")[0];
        if (isStart) {
          fecha1 = picked;
        } else {
          fecha2 = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Nombre del evento'),
          TextFormField(controller: nombreEventoController),

          const SizedBox(height: 15),
          _buildLabel('Dirección Física'),
          TextFormField(controller: direccionController),

          const SizedBox(height: 15),
          _buildLabel('Tipo de evento'),
          DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            hint: const Text("Selecciona el tipo"),
            items: options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedValue = val;
                typeC = val;
              });
            },
          ),

          const SizedBox(height: 20),
          _buildLabel('Ubicación en el Mapa'),
          ListTile(
            tileColor: Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            leading: const Icon(Icons.map, color: Colors.blue),
            title: Text(
              ubicacionTemporal == null
                  ? "Toca para abrir el mapa"
                  : "Punto fijado",
            ),
            onTap: () async {
              final LatLng? resultado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Mapa(
                    esSelector: true,
                    tipoEvento: selectedValue ?? 'Otros',
                  ),
                ),
              );
              if (resultado != null) {
                setState(() {
                  ubicacionTemporal = resultado;
                  latitudC = resultado.latitude;
                  longitudC = resultado.longitude;
                });
              }
            },
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Fecha Inicio"),
                    TextFormField(
                      controller: fecha1C,
                      readOnly: true,
                      onTap: () => _selectDate(context, fecha1C, true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Hora Inicio"),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? t = await showTimePicker(
                          context: context,
                          initialTime: hora1,
                        );
                        if (t != null)
                          setState(() {
                            hora1 = t;
                            firtTimeHour = t;
                          });
                      },
                      child: Text("${hora1.hour}:${hora1.minute}"),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _buildLabel('Descripción'),
          TextFormField(controller: descripcionController, maxLines: 3),

          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => createEvent(context),
                icon: const Icon(Icons.cloud_upload),
                label: const Text('PUBLICAR EVENTO'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}

// --- PANEL DE CONTROL ---
class ControlPanelEvent extends StatelessWidget {
  const ControlPanelEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Eventos")),
      body: const MyEvents(),
    );
  }
}

=======
// --- PANTALLA: MIS EVENTOS (LISTA) ---
>>>>>>> Stashed changes
class MyEvents extends StatefulWidget {
  const MyEvents({super.key});
  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: chargeEvents(),
<<<<<<< Updated upstream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(child: Text("No hay eventos"));

        final eventos = snapshot.data!;
        return ListView.builder(
          itemCount: eventos.length,
          itemBuilder: (context, index) {
            final item = eventos[index];
            return Card(
              child: ListTile(
                title: Text(item['name'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('events')
                        .doc(item['id'])
                        .delete();
                    setState(() {});
                  },
                ),
              ),
            );
          },
=======
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final list = snap.data!;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context, i) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: ListTile(
              title: Text(
                list[i]['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(list[i]['type'] ?? 'Otros'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      idmod = list[i]['id'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const ModifyEvents()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await deleteEvent(list[i]['id']);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
>>>>>>> Stashed changes
        );
      },
    );
  }
}
<<<<<<< Updated upstream
=======

// --- PANTALLA: MODIFICAR EVENTO ---
class ModifyEvents extends StatefulWidget {
  const ModifyEvents({super.key});
  @override
  State<ModifyEvents> createState() => _ModifyEventsState();
}

class _ModifyEventsState extends State<ModifyEvents> {
  @override
  void initState() {
    super.initState();
    cargarDatosEvento(idmod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FIX: Corregido 'app_bar' a 'appBar'
      appBar: const BochincheAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Editar Evento",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nombreEventoController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: "Descripción"),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => modifyEvent(context, idmod),
              child: const Text("GUARDAR CAMBIOS"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WRAPPER PARA PANEL ---
class ControlPanelEvent extends StatelessWidget {
  const ControlPanelEvent({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const BochincheAppBar(),
    drawer: const Navbar(),
    body: const MyEvents(),
  );
} // FIX: Corregido el cierre con ';' por '}'
>>>>>>> Stashed changes
