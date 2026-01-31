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
DateTime? fecha1; // Objeto fecha inicio
DateTime? fecha2; // Objeto fecha fin
TimeOfDay? firtTimeHour; // Hora inicio
TimeOfDay? lastTimeHour; // Hora cierre

// --- VARIABLES DE UBICACIÓN (MAPA) ---
double latitudC = 0.0;
double longitudC = 0.0;

// --- FUNCIÓN PARA CREAR EL EVENTO EN FIRESTORE ---
Future<void> createEvent(BuildContext context) async {
  // Verificación básica: al menos el nombre y la ubicación deben existir
  if (nombreEventoController.text.isEmpty || latitudC == 0.0) {
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
    // Guardar en la colección 'events' de Firebase
    await FirebaseFirestore.instance.collection('events').add({
      'name': nombreEventoController.text,
      'address': direccionController.text,
      'contact': contactoController.text,
      'type': typeC ?? 'Otros',
      'description': descripcionController.text,
      'capacity': aforoController.text,
      'startDate': fecha1C.text,
      'endDate': fecha2C.text,
      'startTime': firtTimeHour != null
          ? '${firtTimeHour!.hour}:${firtTimeHour!.minute}'
          : '',
      'endTime': lastTimeHour != null
          ? '${lastTimeHour!.hour}:${lastTimeHour!.minute}'
          : '',
      // COORDENADAS DEL MAPA
      'lat': latitudC,
      'lng': longitudC,
      'createdAt': FieldValue.serverTimestamp(), // Fecha de creación automática
    });

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Evento creado y ubicado en el mapa con éxito!'),
        backgroundColor: Colors.green,
      ),
    );

    // LIMPIAR TODOS LOS CAMPOS DESPUÉS DE GUARDAR
    clearAllFields();
  } catch (e) {
    // Mostrar error si falla la conexión
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
  }
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
  latitudC = 0.0;
  longitudC = 0.0;
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
