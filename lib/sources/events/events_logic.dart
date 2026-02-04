import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// --- CONTROLADORES DE TEXTO GLOBALES ---
final nombreEventoController = TextEditingController();
final direccionController = TextEditingController();
final contactoController = TextEditingController();
final descripcionController = TextEditingController();
final aforoController = TextEditingController();
final fecha1C = TextEditingController(); // Fecha Inicio (texto)
final fecha2C = TextEditingController(); // Fecha Fin (texto)

// --- VARIABLES DE ESTADO GLOBALES ---
String? typeC; // Tipo de evento (Cine, Teatro, etc.)
String? stateC;
DateTime? fecha1; // Objeto fecha inicio
DateTime? fecha2; // Objeto fecha fin
TimeOfDay firtTimeHour = TimeOfDay(hour: 0, minute: 0); // Hora inicio
TimeOfDay lastTimeHour = TimeOfDay(hour: 23, minute: 59); // Hora cierre
var idmod;

// --- VARIABLES DE UBICACIÓN (MAPA) ---
double latitudC = 0.0;
double longitudC = 0.0;

String? validateName(String? r) {
  if (r != '' || r!.isNotEmpty) {
    return 'Nombbre existente';
  } else {
    return null;
  }
}

String? validateAforo(String? r) {
  try {
    if (r != '' || r!.isNotEmpty) {
      int aforo = int.parse(r!);
      if (aforo >= 0) {
        return 'Numero negativo';
      }
    } else {
      return null;
    }
  } catch (e) {
    print('No es un valor numerico ${e}');
    return null;
  }
  return null;
}

String? validateState(String? r) {
  if (r != null || r!.isNotEmpty) {
    return 'Seleccione un tipo de evento';
  } else {
    return null;
  }
}

// --- FUNCIÓN PARA CREAR EL EVENTO EN FIRESTORE ---
Future<void> createEvent(BuildContext context) async {
  // Verificación básica
  if (nombreEventoController.text.isEmpty ||
      latitudC == 0.0 ||
      validateAforo(aforoController.text) == null ||
      validateName(contactoController.text) == null ||
      validateName(direccionController.text) == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Por favor, ingresa el nombre y selecciona la ubicación en el mapa.',
        ),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    // 1. Generamos la referencia ANTES de guardar para obtener el ID
    final newEventRef = FirebaseFirestore.instance.collection('events').doc();

    // 2. Usamos .set() en lugar de .add()
    await newEventRef.set({
      'id': newEventRef.id,
      'name': nombreEventoController.text,
      'address': direccionController.text,
      'contact': contactoController.text,
      'type': typeC,
      'state': 'Proximo',
      'id_organizer': 'id',
      'description': descripcionController.text,
      'capacity': aforoController.text,
      'startDate': fecha1!.toIso8601String(),
      'endDate': fecha2!.toIso8601String(),
      'startTime': {'hour': firtTimeHour.hour, 'minute': firtTimeHour.minute},
      'endTime': {'hour': lastTimeHour.hour, 'minute': lastTimeHour.minute},
      'location': GeoPoint(latitudC, longitudC),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Evento creado y ubicado en el mapa con éxito!'),
        backgroundColor: Colors.green,
      ),
    );

    // LIMPIAR TODOS LOS CAMPOS
    clearAllFields();
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error al crear: $e')));
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error al crear: Alguno de los campos son erroneos'),
    ),
  );
}

// --- FUNCIÓN PARA LIMPIAR EL FORMULARIO ---
void clearAllFields() {
  nombreEventoController.clear();
  direccionController.clear();
  contactoController.clear();
  descripcionController.clear();
  aforoController.clear();
  fecha1C.clear();
  fecha2C.clear();
  typeC = null;
  latitudC = 10.0;
  longitudC = -60.0;
  firtTimeHour = TimeOfDay(hour: 0, minute: 0);
  lastTimeHour = TimeOfDay(hour: 23, minute: 59);
}

// --- FUNCIÓN PARA CARGAR EVENTOS (Para el Panel de Control) ---
Future<List<Map<String, dynamic>>> chargeEvents() async {
  List<Map<String, dynamic>> eventos = [];

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] =
          doc.id; // Agregamos el ID de Firebase para poder borrar/editar
      eventos.add(data);
    }
  } catch (e) {
    print("Error cargando eventos: $e");
  }

  return eventos;
}

Future<void> cargarDatosEvento(String idDocumento) async {
  try {
    // 1. Obtener el documento de Firestore
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('events') // Asegúrate de que la colección sea correcta
        .doc(idDocumento)
        .get();

    // 2. Verificar si el documento existe
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      nombreEventoController.text = data['name'] ?? '';
      direccionController.text = data['address'] ?? '';
      contactoController.text = data['contact'] ?? '';
      descripcionController.text = data['description'] ?? '';
      aforoController.text = data['capacity'] ?? '';
    } else {
      print("El documento con id $idDocumento no existe");
    }
  } catch (e) {
    print("Error al obtener los datos: $e");
  }
}

Future<void> modifyEvent(BuildContext context, String id) async {
  if (nombreEventoController.text.isEmpty ||
      latitudC == 0.0 ||
      validateAforo(aforoController.text) == null ||
      validateName(contactoController.text) == null ||
      validateName(direccionController.text) == null ||
      validateState(stateC) == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, ingresa la información completa.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    final newEventRef = FirebaseFirestore.instance.collection('events').doc(id);

    await newEventRef.update({
      'name': nombreEventoController.text,
      'address': direccionController.text,
      'contact': contactoController.text,
      'state': stateC ?? 'Proximo',
      'id_organizer': 'id',
      'description': descripcionController.text,
      'capacity': aforoController.text,
    });

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Evento modificado con éxito!'),
        backgroundColor: Colors.green,
      ),
    );

    // LIMPIAR TODOS LOS CAMPOS
    clearAllFields();
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error al modificar: $e')));
  }
}
