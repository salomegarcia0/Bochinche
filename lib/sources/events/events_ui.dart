import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/map/Paginna_Inicio.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

// --- CORRECCIÓN DE RUTAS ---
// Usamos 'package:' que es la forma más segura en Flutter para evitar errores de ruta
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/features/map/mapa_2.dart';
import 'package:bochinche_app/sources/events/comments_section.dart';
import 'package:bochinche_app/features/payment/payment_page.dart';

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
  bool isPrivateLocal = false;

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
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isPrivateLocal ? Colors.purple.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isPrivateLocal ? PrimaryPurple : Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Evento Privado'),
                    Text(
                      isPrivateLocal ? "Solo con código" : "Visible para todos",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Switch(
                  activeColor: PrimaryPurple,
                  value: isPrivateLocal,
                  onChanged: (bool value) {
                    setState(() {
                      isPrivateLocal = value;
                      isPrivate = value; // Actualizamos la variable global
                    });
                  },
                ),
              ],
            ),
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
                .map((b) => DropdownMenuItem(
                      value: b,
                      child: Text(b, overflow: TextOverflow.ellipsis),
                    ))
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  items: phonePrefixList
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child:
                                Text(p, overflow: TextOverflow.ellipsis),
                          ))
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  items: ciTypeList
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              '$t - ${ciTypeLabels[t]}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
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
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
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
                              const Text(
                                'Organizador',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Aforo: ${i['capacity']}',
                                style: const TextStyle(color: Colors.black, fontSize: 13),
                              ),
                              Text(
                                'Contacto: ${i['contact']}',
                                style: const TextStyle(color: Colors.black, fontSize: 13),
                              ),
                              Text(
                                'Tipo: ${i['type']}',
                                style: const TextStyle(color: Colors.black, fontSize: 13),
                              ),
                              Text(
                                'Direccion corta: ${i['address']}',
                                style: const TextStyle(color: Colors.black, fontSize: 13),
                              ),
                              Text(
                                'Descripción: ${i['description']}',
                                style: const TextStyle(color: Colors.black, fontSize: 13),
                              ),
                              Text(
                                'Fechas: ${DateTime.parse(i['startDate']).day}/${DateTime.parse(i['startDate']).month}/${DateTime.parse(i['startDate']).year} hasta ${DateTime.parse(i['endDate']).day}/${DateTime.parse(i['endDate']).month}/${DateTime.parse(i['endDate']).year}',
                                style: const TextStyle(color: Colors.black, fontSize: 13),
                              ),
                              Text(
                                'Horarios: ${i['startTime']['hour']}:${i['startTime']['minute'].toString().padLeft(2, '0')} hasta ${i['endTime']['hour']}:${i['endTime']['minute'].toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.black, fontSize: 13),
                              ),
                              Text(
                                'Localización: ${i['location'].latitude}, ${i['location'].longitude}',
                                style: const TextStyle(color: Colors.black, fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  idmod = i['id'];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ModifyEvents(),
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
                                      Icon(Icons.lock, size: 16, color: Colors.orange),
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
                                      ScaffoldMessenger.of(context).showSnackBar(
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
                              ElevatedButton.icon(
                                onPressed: (int.tryParse(i['capacity']?.toString() ?? '0') ?? 0) <= (i['ticketsSold'] ?? 0)
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentPage(
                                              eventData: i,
                                              eventId: i['id'],
                                            ),
                                          ),
                                        );
                                      },
                                icon: const Icon(Icons.payment),
                                label: Text(
                                  (int.tryParse(i['capacity']?.toString() ?? '0') ?? 0) <= (i['ticketsSold'] ?? 0)
                                      ? 'Agotado'
                                      : 'Pagar',
                                ),
                              ),
                              const SizedBox(height: 10),
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
  bool isPrivateLocal = false;

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
          
          // --- 3. AGREGAMOS EL SWITCH DE PRIVACIDAD AQUÍ ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isPrivateLocal ? Colors.purple.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isPrivateLocal ? PrimaryPurple : Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Evento Privado'),
                    Text(
                      isPrivateLocal ? "Privado (Solo con invitación)" : "Público (Visible para todos)",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Switch(
                  activeColor: PrimaryPurple,
                  value: isPrivateLocal,
                  onChanged: (bool value) {
                    setState(() {
                      isPrivateLocal = value;
                      isPrivate = value; 
                    });
                  },
                ),
              ],
            ),
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
                .map((b) => DropdownMenuItem(
                      value: b,
                      child: Text(b, overflow: TextOverflow.ellipsis),
                    ))
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  items: phonePrefixList
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child:
                                Text(p, overflow: TextOverflow.ellipsis),
                          ))
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  items: ciTypeList
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              '$t - ${ciTypeLabels[t]}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
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

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'guest';

    final doc = await FirebaseFirestore.instance
        .collection('users')
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

              if (role == 'guest')
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Iniciar sesión'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar sesión'),
                  onTap: () {
                    clearAllFields();
                    FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (data['isPrivate'] ?? false) ? Colors.red[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (data['isPrivate'] ?? false) ? Colors.red : Colors.green,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            (data['isPrivate'] ?? false) ? Icons.lock_outline : Icons.public,
                            size: 16,
                            color: (data['isPrivate'] ?? false) ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            (data['isPrivate'] ?? false) ? 'EVENTO PRIVADO' : 'EVENTO PÚBLICO',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: (data['isPrivate'] ?? false) ? Colors.red : Colors.green,
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
