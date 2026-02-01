import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

// --- CORRECCIÓN DE RUTAS ---
// Usamos 'package:' que es la forma más segura en Flutter para evitar errores de ruta
import 'package:bochinche_app/sources/events/events_logic.dart';
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
  String? selectedValue2;
  TimeOfDay hora1select = TimeOfDay.now();
  TimeOfDay hora2select = TimeOfDay.now();
  TimeOfDay hora1 = TimeOfDay.now();

  Future<void> fechaselect2(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
    );

    if (date != null) {
      setState(() {
        fecha2C.text = date.toString().split(" ")[0];
        fecha2 = date;
      });
    }
  }

  Future<void> fechaselect1(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
    );

    if (date != null) {
      setState(() {
        fecha1C.text = date.toString().split(" ")[0];
        fecha1 = date;
      });
    }
  }

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
          _buildLabel('Fecha Inicio'),
          TextField(
            controller: fecha1C,
            decoration: InputDecoration(
              filled: true,
              prefix: Icon(Icons.calendar_view_day_rounded),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
            readOnly: true,
            onTap: () {
              fechaselect1(context);
              print(fecha1C);
            },
          ),
          _buildLabel('Fecha Fin'),
          TextField(
            controller: fecha2C,
            decoration: InputDecoration(
              filled: true,
              prefix: Icon(Icons.calendar_view_day_rounded),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
            readOnly: true,
            onTap: () {
              fechaselect2(context);
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Hora de inicio"),

                    Padding(
                      padding: EdgeInsetsGeometry.all(2),
                      child: Container(
                        decoration: BoxDecoration(
                          border: BoxBorder.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          '${hora1select.hour}:${hora1select.minute}',
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      child: Text('Elige la hora de inicio del evento'),
                      onPressed: () async {
                        final TimeOfDay? horaFirst = await showTimePicker(
                          context: context,
                          initialTime: hora1select,
                          initialEntryMode: TimePickerEntryMode.dial,
                        );
                        if (horaFirst != null) {
                          setState(() {
                            hora1select = horaFirst;
                            firtTimeHour = hora1select;
                            print(hora1select.hour);
                            print(hora1select.minute);
                          });
                        }
                      },
                    ),
                    _buildLabel("Hora de cierre"),
                    Padding(
                      padding: EdgeInsetsGeometry.all(2),
                      child: Container(
                        decoration: BoxDecoration(
                          border: BoxBorder.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          '${hora2select.hour}:${hora2select.minute} ',
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      child: Text('Elige la hora de cierre del evento'),
                      onPressed: () async {
                        final TimeOfDay? horaLast = await showTimePicker(
                          context: context,
                          initialTime: hora2select,
                          initialEntryMode: TimePickerEntryMode.dial,
                        );
                        if (horaLast != null) {
                          setState(() {
                            hora2select = horaLast;
                            lastTimeHour = hora2select;
                            print(hora2select.hour);
                            print(hora2select.minute);
                          });
                        }
                      },
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Panel de control para gestionar eventos',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          MyEvents(),
        ],
      ),
    );
  }
}

class MyEvents extends StatefulWidget {
  //Esto con el tiempo se validará mejor
  const MyEvents({super.key});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  String obtainIDFromEvent(String id) {
    return id;
  }

  Future<void> deleteEvent(String id) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(id).delete();
    } catch (e) {
      print('Error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<dynamic>>(
          future: chargeEvents(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final eventos = snapshot.data!;
              return Column(
                children: eventos
                    .map(
                      (i) => Padding(
                        padding: EdgeInsetsGeometry.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: BoxBorder.all(color: Colors.black),
                          ),
                          child: Column(
                            children: [
                              Text(
                                i['name'],
                                style: TextStyle(color: Colors.black),
                              ),
                              ElevatedButton(
                                onPressed: null,
                                child: Row(
                                  children: [
                                    Icon(Icons.change_circle),
                                    Text('Modificar evento'),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  try {
                                    setState(() {
                                      deleteEvent(obtainIDFromEvent(i['id']));
                                    });
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.delete),
                                    Text('Eliminar evento'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }
            return LinearProgressIndicator();
          },
        ),
      ],
    );
  }
}
