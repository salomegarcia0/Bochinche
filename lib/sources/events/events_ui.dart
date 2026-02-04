import 'dart:ui';
import 'package:bochinche_app/data/auth_service.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/map/Paginna_Inicio.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

// --- CORRECCIÓN DE RUTAS ---
// Usamos 'package:' que es la forma más segura en Flutter para evitar errores de ruta
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/features/map/mapa_2.dart';

class EventosCreate extends StatelessWidget {
  const EventosCreate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navbar(),
      appBar: BochincheAppBar(),
      body: const SingleChildScrollView(
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
  TimeOfDay hora1select = firtTimeHour;
  TimeOfDay hora2select = lastTimeHour;
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
          TextFormField(
            controller: nombreEventoController,
            validator: validateName,
          ),

          const SizedBox(height: 15),
          _buildLabel('Dirección Física'),
          TextFormField(
            controller: direccionController,
            validator: validateName,
          ),

          const SizedBox(height: 15),
          _buildLabel('Contacto o Pagina Web'),
          TextFormField(
            controller: contactoController,
            validator: validateName,
          ),

          const SizedBox(height: 15),
          _buildLabel('Aforo'),
          TextFormField(controller: aforoController, validator: validateAforo),

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
            decoration: const InputDecoration(
              hintText: 'Fecha de inicio del evento',
              filled: true,
              prefixIcon: Icon(Icons.calendar_view_day_rounded),
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
            decoration: const InputDecoration(
              hintText: 'Fecha de fin del evento',
              filled: true,
              prefixIcon: Icon(Icons.calendar_view_day_rounded),
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
            leading: const Icon(Icons.map, color: PrimaryPurple),
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

          _buildLabel("Hora de inicio"),
          Row(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.all(2),
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 5,
                    bottom: 5,
                  ),
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    '${hora1select.hour}:${hora1select.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
              ),
              ElevatedButton(
                child: Icon(Icons.punch_clock),
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
            ],
          ),

          _buildLabel("Hora de cierre"),
          Row(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.all(2),
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 5,
                    bottom: 5,
                  ),
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    '${hora2select.hour}:${hora2select.minute.toString().padLeft(2, '0')} ',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
              ),
              ElevatedButton(
                child: Icon(Icons.punch_clock),
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
                  backgroundColor: PrimaryPurple,
                  foregroundColor: SecondaryPurple,
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
      drawer: const Navbar(),
      appBar: BochincheAppBar(),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(13),

          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: MyEvents(),
          ),
        ),
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
        Text(
          'Panel de control de eventos',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        Text(
          'Aqui puedes ver todos tus eventos creados',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
        ),
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
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: BoxBorder.all(color: Colors.black),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i['name'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                'Organizador',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Aforo: ${i['capacity']}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Contacto: ${i['contact']}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Tipo: ${i['type']}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Direccion corta: ${i['address']}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Descripción: ${i['description']}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Fechas: ${DateTime.parse(i['startDate']).day}/${DateTime.parse(i['startDate']).month}/${DateTime.parse(i['startDate']).year} hasta ${DateTime.parse(i['endDate']).day}/${DateTime.parse(i['endDate']).month}/${DateTime.parse(i['endDate']).year}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Horarios: ${i['startTime']['hour']}:${i['startTime']['minute'].toString().padLeft(2, '0')} hasta ${i['endTime']['hour']}:${i['endTime']['minute'].toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Localización: ${i['location'].latitude}, ${i['location'].longitude}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  idmod = i['id'];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ModifyEvents(),
                                    ),
                                  );
                                  cargarDatosEvento(idmod);
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.change_circle),
                                    Text('Modificar evento'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
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

class ModifyEvents extends StatelessWidget {
  const ModifyEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navbar(),
      appBar: BochincheAppBar(),
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
            const FormCreateEvent2(),
          ],
        ),
      ),
    );
  }
}

class FormCreateEvent2 extends StatefulWidget {
  const FormCreateEvent2({super.key});

  @override
  State<FormCreateEvent2> createState() => _FormCreateEvent2State();
}

class _FormCreateEvent2State extends State<FormCreateEvent2> {
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

  final List<String> options2 = [
    'Proximo',
    'Ocurriendo',
    'Terminado',
    'Cancelado',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Nombre del evento'),
          TextFormField(
            controller: nombreEventoController,
            validator: validateName,
          ),

          const SizedBox(height: 15),
          _buildLabel('Dirección Física'),
          TextFormField(
            controller: direccionController,
            validator: validateName,
          ),

          const SizedBox(height: 15),
          _buildLabel('Contacto'),
          TextFormField(
            controller: contactoController,
            validator: validateName,
          ),

          const SizedBox(height: 15),
          _buildLabel('Aforo'),
          TextFormField(controller: aforoController, validator: validateAforo),

          const SizedBox(height: 15),
          _buildLabel('Estado del evento'),
          DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            hint: const Text("Selecciona el estado"),
            items: options2
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedValue = val;
                stateC = val;
              });
            },
          ),

          _buildLabel('Descripción'),
          TextFormField(controller: descripcionController, maxLines: 3),

          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PrimaryPurple,
                  foregroundColor: SecondaryPurple,
                ),
                onPressed: () {
                  modifyEvent(context, idmod);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ControlPanelEvent(),
                    ),
                  );
                },
                icon: const Icon(Icons.cloud_upload),
                label: const Text('MODIFICAR EVENTO'),
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

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  // Función para obtener el rol desde Firestore
  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'guest';

    final doc = await FirebaseFirestore.instance
        .collection('users') // Asegúrate que tu colección se llame así
        .doc(user.uid)
        .get();

    return doc.data()!['rol'];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<String>(
        future: _getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final String role = snapshot.data ?? 'user';
          final bool isOrganizador = role == 'organizador';

          return ListView(
            children: [
              _buildListTile(
                context,
                Icons.map,
                'Mapa',
                const Pagina_Principal(),
              ),

              // ESTOS SE OCULTAN SI ES ORGANIZADOR
              if (isOrganizador) ...[
                _buildListTile(
                  context,
                  Icons.view_array,
                  'Crear eventos',
                  const EventosCreate(),
                ),
                _buildListTile(
                  context,
                  Icons.view_array,
                  'Panel de control',
                  const ControlPanelEvent(),
                ),
              ],

              // ESTE SE MUESTRA SIEMPRE
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Salir de sesion'),
                onTap: () {
                  clearAllFields();
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false, // Limpia el historial de navegación
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Función auxiliar para no repetir código de navegación
  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        clearAllFields();
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}
