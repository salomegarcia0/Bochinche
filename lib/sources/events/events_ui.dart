import 'dart:ui';
import 'package:bochinche_app/sources/events_logic.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventosCreate extends StatelessWidget {
  const EventosCreate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Card(
              color: Color(0),
              margin: EdgeInsets.all(23),
              child: Text(
                'Crear tus eventos y promocionarlos al mundo',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 25,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.create),
                  SizedBox(width: 8),
                  Text('Ver eventos'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ControlPanelEvent()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.create),
                  SizedBox(width: 8),
                  Text('Panel de control'),
                ],
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
  String? selectedValue;
  String? selectedValue2;
  TimeOfDay hora1select = TimeOfDay.now();
  TimeOfDay hora2select = TimeOfDay.now();

  final List<String> options = [
    'Concierto',
    'Conferencias',
    'Stand Up',
    'Teatro',
    'Fiestas',
    'Convenciones',
    'Otros',
  ];

  final List<String> state = [
    'Proximo',
    'En Vivo',
    'Pospuesto',
    'Finalizado'
        'Cancelado',
  ];

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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: GestureDetector(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nombre del evento',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Colors.black),
                  ),
                  child: TextFormField(
                    controller: nombreEventoController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(4),
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              const Text(
                'Dirección',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              TextFormField(maxLines: 1, controller: direccionController),
              const SizedBox(height: 15),
              const Text(
                'Contacto',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              TextFormField(maxLines: 1, controller: contactoController),
              const SizedBox(height: 15),
              const Text(
                'Tipo de evento',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              DropdownButton<String>(
                value: selectedValue,
                hint: const Text("Selecciona tipo de evento"),
                isExpanded: true,
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue;
                    typeC = selectedValue;
                  });
                },
              ),
              const SizedBox(height: 15),
              Text(
                'Fecha de inicio del evento',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
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
              Text(
                'Fecha de fin del evento',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
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
              Text(
                'Hora de inicio del evento',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
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
              Text(
                'Hora de cierre del evento',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
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
              const Text(
                'Descripción',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              TextFormField(maxLines: 5, controller: descripcionController),
              const Text(
                'Aforo del evento',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              TextFormField(maxLines: 1, controller: aforoController),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    createEvent(context);
                    dispose();
                    /*
                    navigator
                     */
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.create),
                      SizedBox(width: 8),
                      Text('Crear evento'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
