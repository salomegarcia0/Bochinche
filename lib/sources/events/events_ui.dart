import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/map/Paginna_Inicio.dart';
import 'package:bochinche_app/sources/reports/reports_logic.dart';
import 'package:bochinche_app/sources/reports/reports_ui.dart';
import 'package:bochinche_app/sources/user_profile/user_profile_ui.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/styles/Color.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import 'package:bochinche_app/styles/NavBar.dart';

// --- CORRECCIÓN DE RUTAS ---
// Usamos 'package:' que es la forma más segura en Flutter para evitar errores de ruta
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/features/map/mapa_2.dart';
import 'package:bochinche_app/sources/events/comments_section.dart';
import 'package:bochinche_app/features/payment/payment_page.dart';

bool botonVerEventos = true;

enum SearchMode { eventos, privados, bochincheros }

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
            Card(
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

            Divider(),
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
          TextFormField(
            controller: nombreEventoController,
            validator: validateName,
            decoration: const InputDecoration(
              labelText: 'Nombre del evento',
              prefixIcon: Icon(Icons.event),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: direccionController,
            validator: validateName,
            decoration: const InputDecoration(
              labelText: 'Dirección Física',
              prefixIcon: Icon(Icons.pin_drop),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: contactoController,
            validator: validateName,
            decoration: const InputDecoration(
              labelText: 'Contacto o Pagina Web',
              prefixIcon: Icon(Icons.contact_page),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: aforoController,
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: validateAforo,
            decoration: const InputDecoration(
              labelText: 'Aforo',
              prefixIcon: Icon(Icons.people),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Tipo de evento',
              prefixIcon: Icon(Icons.type_specimen),
              border: OutlineInputBorder(),
            ),
            initialValue: selectedValue,
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
          SizedBox(height: 12),
          TextField(
            controller: fecha1C,
            decoration: const InputDecoration(
              labelText: 'Fecha de inicio del evento',
              filled: true,
              prefixIcon: Icon(Icons.calendar_view_day_rounded),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 3, 3, 3)),
              ),
            ),
            readOnly: true,
            onTap: () {
              fechaselect1(context);
              print(fecha1C);
            },
          ),
          SizedBox(height: 12),
          TextField(
            controller: fecha2C,
            decoration: const InputDecoration(
              labelText: 'Fecha de fin del evento',
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

          const SizedBox(height: 12),

          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
              SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descripcionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción del evento',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),

          // --- PRIVACIDAD ---
          _buildLabel('Privacidad del Evento'),
          SwitchListTile(
            title: Text(isPrivateC ? 'Evento Privado' : 'Evento Público'),
            subtitle: Text(
              isPrivateC
                  ? 'Solo accesible mediante enlace de invitación'
                  : 'Visible para todos en el mapa',
            ),
            value: isPrivateC,
            activeThumbColor: PrimaryPurple,
            secondary: Icon(
              isPrivateC ? Icons.lock : Icons.public,
              color: isPrivateC ? PrimaryPurple : Colors.grey,
            ),
            onChanged: (val) => setState(() => isPrivateC = val),
          ),

          const SizedBox(height: 20),
          const Divider(),

          SwitchListTile(
            title: Text(isPayedC ? 'Evento Pago' : 'Evento Gratuito'),
            value: isPayedC,
            // ... resto de tu configuración actual
            onChanged: (val) => setState(() => isPayedC = val),
          ),

          // --- AQUÍ LA MAGIA ---
          if (isPayedC) ...[
            _buildLabel('Datos de Pago (Pago Móvil)'),
            const SizedBox(height: 4),
            const Text(
              'Ingresa los datos donde los compradores realizarán el pago.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            // --- Banco (Dropdown) ---
            DropdownButtonFormField<String>(
              initialValue: selectedBank,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Banco',
                prefixIcon: Icon(Icons.account_balance),
                border: OutlineInputBorder(),
              ),
              items: bankList
                  .map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Text(b, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => selectedBank = val),
            ),
            const SizedBox(height: 12),

            // --- Teléfono (Prefijo dropdown + número) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedPhonePrefix,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Prefijo',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                    ),
                    items: phonePrefixList
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(p, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedPhonePrefix = val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: paymentPhoneNumberController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    maxLength: 7,
                    decoration: const InputDecoration(
                      labelText: 'Número',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedCIType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                    ),
                    items: ciTypeList
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              '$t - ${ciTypeLabels[t]}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedCIType = val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: paymentCINumberController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Número de Identificación',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Precio por Entrada (Bs)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
          ] else ...[
            // Opcional: widgets que solo se ven si es GRATUITO
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Este evento será visible para todos de forma gratuita.",
              ),
            ),
          ],

          // --- DATOS DE PAGO ---
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
                  createEvent(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ControlPanelEvent(),
                    ),
                  );
                },
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
        Divider(),

        FutureBuilder<List<dynamic>>(
          future: chargeEvents(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final eventos = snapshot.data!;
              return Column(
                children: eventos
                    .map(
                      (i) => Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i['name'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Aforo: ${i['capacity']}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Contacto: ${i['contact']}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Tipo: ${i['type']}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Direccion corta: ${i['address']}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Descripción: ${i['description']}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Fechas: ${DateTime.parse(i['startDate']).day}/${DateTime.parse(i['startDate']).month}/${DateTime.parse(i['startDate']).year} hasta ${DateTime.parse(i['endDate']).day}/${DateTime.parse(i['endDate']).month}/${DateTime.parse(i['endDate']).year}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Horarios: ${i['startTime']['hour']}:${i['startTime']['minute'].toString().padLeft(2, '0')} hasta ${i['endTime']['hour']}:${i['endTime']['minute'].toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Localización: ${i['location'].latitude}, ${i['location'].longitude}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 10),

                              const SizedBox(height: 10),
                              if (i['isPrivate'] == true) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.orange),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.lock,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Evento Privado',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: i['id']),
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Código de invitación copiado: ${i['id']}',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.link),
                                  label: const Text('Copiar Código'),
                                ),
                                const SizedBox(height: 10),
                              ],

                              const SizedBox(height: 10),
                              Wrap(
                                children: [
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
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.change_circle),
                                        SizedBox(width: 5),
                                        Text('Modificar evento'),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      try {
                                        setState(() {
                                          deleteEvent(
                                            obtainIDFromEvent(i['id']),
                                          );
                                        });
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.delete),
                                        SizedBox(width: 5),
                                        Text('Eliminar evento'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }
            return CircularProgressIndicator();
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
                  'Modifica tus eventos',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
                ),
              ),
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
          TextFormField(
            controller: nombreEventoController,
            validator: validateName,
            decoration: const InputDecoration(
              labelText: 'Nombre del evento',
              prefixIcon: Icon(Icons.event),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: direccionController,
            validator: validateName,
            decoration: const InputDecoration(
              labelText: 'Dirección Física',
              prefixIcon: Icon(Icons.pin_drop),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: contactoController,
            validator: validateName,
            decoration: const InputDecoration(
              labelText: 'Contacto o Pagina Web',
              prefixIcon: Icon(Icons.contact_page),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: aforoController,
            validator: validateAforo,
            decoration: const InputDecoration(
              labelText: 'Aforo',
              prefixIcon: Icon(Icons.people),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Estado del evento',
              prefixIcon: Icon(Icons.event_available),
              border: OutlineInputBorder(),
            ),
            initialValue: selectedValue,
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
          SizedBox(height: 12),
          TextFormField(
            controller: descripcionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción del evento',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),

          // --- DATOS DE PAGO ---
          _buildLabel('Datos de Pago (Pago Móvil)'),
          const SizedBox(height: 4),
          const Text(
            'Ingresa los datos donde los compradores realizarán el pago.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          // --- Banco (Dropdown) ---
          DropdownButtonFormField<String>(
            initialValue: selectedBank,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Banco',
              prefixIcon: Icon(Icons.account_balance),
              border: OutlineInputBorder(),
            ),
            items: bankList
                .map(
                  (b) => DropdownMenuItem(
                    value: b,
                    child: Text(b, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => selectedBank = val),
          ),
          const SizedBox(height: 12),

          // --- Teléfono (Prefijo dropdown + número) ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedPhonePrefix,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Prefijo',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
                  items: phonePrefixList
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedPhonePrefix = val),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: paymentPhoneNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 7,
                  decoration: const InputDecoration(
                    labelText: 'Número',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- Cédula / Identificación (Tipo dropdown + número) ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedCIType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
                  items: ciTypeList
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            '$t - ${ciTypeLabels[t]}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedCIType = val),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: paymentCINumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Número de Identificación',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Precio por Entrada (Bs)',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
          ),

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

class DetalleEvento extends StatefulWidget {
  const DetalleEvento({super.key});

  @override
  State<DetalleEvento> createState() => _DetalleEventoState();
}

class _DetalleEventoState extends State<DetalleEvento> {
  final String idDelEvento = "ID_DEL_EVENTO";
  final commentsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Evento')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('events')
            .doc(idDelEvento)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Evento no encontrado'));
          }

          final evento = snapshot.data!;
          final Map<String, dynamic> data =
              evento.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (data['isPrivate'] ?? false)
                          ? Colors.red[50]
                          : Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (data['isPrivate'] ?? false)
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (data['isPrivate'] ?? false)
                              ? Icons.lock_outline
                              : Icons.public,
                          size: 16,
                          color: (data['isPrivate'] ?? false)
                              ? Colors.red
                              : Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          (data['isPrivate'] ?? false)
                              ? 'EVENTO PRIVADO'
                              : 'EVENTO PÚBLICO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: (data['isPrivate'] ?? false)
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Organizador: ${data['organizer'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tipo: ${data['type'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estado: ${data['status'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aforo: ${data['capacity'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contacto: ${data['contact'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dirección: ${data['address'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Descripción: ${data['description'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fechas: ${DateTime.parse(data['startDate']).day}/${DateTime.parse(data['startDate']).month}/${DateTime.parse(data['startDate']).year} hasta ${DateTime.parse(data['endDate']).day}/${DateTime.parse(data['endDate']).month}/${DateTime.parse(data['endDate']).year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Horarios: ${data['startTime']['hour']}:${data['startTime']['minute'].toString().padLeft(2, '0')} hasta ${data['endTime']['hour']}:${data['endTime']['minute'].toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Localización: ${data['location'].latitude}, ${data['location'].longitude}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Registrarse en este evento'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Scrollable.ensureVisible(
                        commentsKey.currentContext!,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Dejar un comentario'),
                  ),
                  const SizedBox(height: 20),
                  CommentsSection(key: commentsKey, eventoId: idDelEvento),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

//ESTOS SON LOS CAMBIOS DE JAVIER

class PublicEventsScreen extends StatefulWidget {
  const PublicEventsScreen({super.key});
  @override
  State<PublicEventsScreen> createState() => _PublicEventsScreenState();
}

final List<String> categoriasEventos = [
  'Todos',
  'Seguidos',
  'Concierto',
  'Teatro',
  'Fiestas',
  'Stand Up',
  'Cine',
  'Otros',
];

final List<String> categoriasUsuarios = ['Todos', 'Seguidos'];

class _PublicEventsScreenState extends State<PublicEventsScreen> {
  late String selectedCategory;
  DateTime? selectedDate;
  late List<String> selectedPreferences;
  bool _isLoading = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCategory = userPreferredFilters['category'];
    selectedPreferences = List<String>.from(userPreferredFilters['tags']);
  }

  Future<void> _fakeLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Determinamos si estamos buscando usuarios basándonos en los chips;
    SearchMode currentMode = SearchMode.eventos; // Por defecto
    if (selectedPreferences.contains('Eventos privados')) {
      currentMode = SearchMode.privados;
    } else if (selectedPreferences.contains('Bochincheros')) {
      currentMode = SearchMode.bochincheros;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: BochincheAppBar(),
      drawer: const Navbar(),
      body: Column(
        children: [
          // --- TÍTULO Y BOTÓN RESET ---
          Padding(
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
                      selectedDate = null;
                      _searchController?.clear();
                      searchQuery = '';
                    });
                    _fakeLoading();
                  },
                  icon: const Icon(
                    Icons.filter_alt_off,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          // --- BUSCADOR DINÁMICO ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => searchQuery = val,
              decoration: InputDecoration(
                hintText: currentMode == SearchMode.bochincheros
                    ? 'Buscar bochincheros...'
                    : (currentMode == SearchMode.privados
                          ? 'Ingresa código de acceso...'
                          : 'Buscar eventos públicos...'),
                prefixIcon: const Icon(Icons.search, color: PrimaryPurple),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PrimaryPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      // Al presionar, activamos la carga con el searchQuery actual
                      setState(() {});
                      _fakeLoading();
                    },
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: InputBorder.none,
                  ),
                  items:
                      (selectedPreferences.contains('Bochincheros')
                              ? categoriasUsuarios
                              : categoriasEventos)
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),

                  onChanged: (val) {
                    setState(() => selectedCategory = val!);
                    _fakeLoading();
                  },
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
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: PrimaryPurple,
                          checkmarkColor: Colors
                              .white, // Para que el check sea blanco al seleccionar
                          onSelected: (bool s) {
                            setState(() {
                              // LIMPIAMOS la lista y añadimos solo el nuevo valor
                              selectedPreferences.clear();

                              if (s) {
                                selectedPreferences.add(pref);
                              } else {
                                // Si deselecciona el que ya estaba, volvemos a 'Todos' por defecto
                                selectedPreferences.add('Todos');
                              }
                            });

                            // Esto hará que el StreamBuilder detecte el cambio y busque en Firebase
                            _fakeLoading();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const BochincheFilterLoader()
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: chargeFilteredEvents(
                      mode: currentMode, // El modo que calculamos con los chips
                      category: selectedCategory,
                      search: searchQuery,
                      date: selectedDate,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const BochincheFilterLoader();
                      final data = snapshot.data ?? [];
                      if (data.isEmpty) {
                        return const Center(
                          child: Text("Sin resultados coincidentes"),
                        );
                      }
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];

                          // Escenario 1: Bochincheros (Usuarios)
                          if (currentMode == SearchMode.bochincheros) {
                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(item['nombre'] ?? 'Sin nombre'),
                                subtitle: Text(
                                  "ID: ${item['cedula'] ?? 'N/A'}",
                                ),
                                onTap: () {
                                  userToReport = item['uid'];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrgProfile(),
                                    ),
                                  );
                                },
                              ),
                            );
                          }

                          // Escenario 2 y 3: Eventos (Públicos o Privados)
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(
                                  currentMode == SearchMode.privados
                                      ? Icons.lock_outline
                                      : Icons.celebration,
                                ),
                              ),
                              title: Text(item['name'] ?? 'Evento sin nombre'),
                              subtitle: Text(
                                "${item['type']} • ${item['startDate']}",
                              ),
                              onTap: () {},
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
