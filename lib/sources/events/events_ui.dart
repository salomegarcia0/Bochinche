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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        );
      },
    );
  }
}
