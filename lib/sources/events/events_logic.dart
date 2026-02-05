import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/data/auth_service.dart';

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
      'id_organizer': FirebaseAuth.instance.currentUser!.uid,
      'description': descripcionController.text,
      'capacity': aforoController.text,
      'startDate': fecha1!.toIso8601String(),
      'endDate': fecha2!.toIso8601String(),
      'startTime': {'hour': firtTimeHour.hour, 'minute': firtTimeHour.minute},
      'endTime': {'hour': lastTimeHour.hour, 'minute': lastTimeHour.minute},
      'location': GeoPoint(latitudC, longitudC),
      'createdAt': FieldValue.serverTimestamp(),
      'stars': 0,
      'total_review': 0,
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
        .where(
          'id_organizer',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
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
      'state': stateC ?? 'Próximo',
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

// --- COMENTARIOS Y VALORACIONES ---
Future<void> agregarComentario({
  required String eventoId,
  required String texto,
  required String usuarioNombre,
  required String usuarioUid,
  int? rating,
}) async {
  try {
    final comentariosColl = FirebaseFirestore.instance
        .collection('events')
        .doc(eventoId)
        .collection('comments');
    await comentariosColl.add({
      'usuarioUid': usuarioUid,
      'nombre': usuarioNombre,
      'texto': texto,
      'rating': rating ?? 0,
      'fecha': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print("Error al guardar comentario: $e");
    rethrow;
  }
}

Stream<List<Map<String, dynamic>>> obtenerComentariosStream(String eventoId) {
  return FirebaseFirestore.instance
      .collection('events')
      .doc(eventoId)
      .collection('comments')
      .orderBy('fecha', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => {...(d.data() as Map<String, dynamic>), 'id': d.id})
            .toList(),
      );
}

/// Agrega o actualiza la valoración del usuario y actualiza promedio de forma atómica.
Future<void> agregarValoracion({
  required String eventoId,
  required int rating, // 1..5
  required String usuarioUid,
}) async {
  final eventRef = FirebaseFirestore.instance
      .collection('events')
      .doc(eventoId);
  final userRatingRef = eventRef.collection('ratings').doc(usuarioUid);

  await FirebaseFirestore.instance.runTransaction((tx) async {
    final eventSnap = await tx.get(eventRef);
    if (!eventSnap.exists) throw Exception('Evento no existe');

    final Map<String, dynamic> eventData =
        eventSnap.data() as Map<String, dynamic>? ?? {};
    final int total = (eventData['total_review'] ?? 0) is int
        ? (eventData['total_review'] ?? 0) as int
        : (eventData['total_review'] ?? 0).toInt();
    final double stars = (eventData['stars'] ?? 0).toDouble();

    int previous = 0;
    final userRatingSnap = await tx.get(userRatingRef);
    bool hadPrevious = userRatingSnap.exists;
    if (hadPrevious) {
      previous = (userRatingSnap.data() as Map<String, dynamic>)['rating'] ?? 0;
    }

    int newTotal = total;
    double newStars;
    if (hadPrevious) {
      // reemplaza la valoración previa
      newStars = (stars * total - previous + rating) / (total == 0 ? 1 : total);
    } else {
      newTotal = total + 1;
      newStars = (stars * total + rating) / newTotal;
    }

    tx.set(userRatingRef, {
      'rating': rating,
      'usuarioUid': usuarioUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    tx.update(eventRef, {'stars': newStars, 'total_review': newTotal});
  });
}
