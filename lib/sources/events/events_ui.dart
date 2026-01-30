import 'dart:ui';
import 'package:bochinche_app/sources/events_logic.dart';
import 'package:flutter/material.dart';

class EventosCreate extends StatelessWidget {
  const EventosCreate({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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
              onPressed: null,
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
  final List<String> options = [
    'Concierto',
    'Conferencias',
    'Stand Up',
    'Teatro',
    'Fiestas',
    'Convenciones',
    'Otros',
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
        fecha1.text = date.toString().split(" ")[0];
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
        fecha2.text = date.toString().split(" ")[0];
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
              TextFormField(
                decoration: InputDecoration(contentPadding: EdgeInsets.all(4)),
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
              const TextField(maxLines: 1),
              const SizedBox(height: 15),
              const Text(
                'Contacto',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const TextField(maxLines: 1),
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
                controller: fecha1,
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
                controller: fecha2,
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

              const Text(
                'Descripción',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const TextField(maxLines: 5),
              const Text(
                'Aforo del evento',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const TextField(maxLines: 1),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    null;
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
        ],
      ),
    );
  }
}
