<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SearchMode { eventos, privados, bochincheros }

String? eventToReport;
String? userToReport;
String idmod = "";

=======
import 'dart:math';
import 'package:bochinche_app/sources/events/events_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:bochinche_app/sources/events/events_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/core/utils/draft_manager.dart';

Future<void> saveEventDraft() async {
  final Map<String, dynamic> data = {
    'name': nombreEventoController.text,
    'address': direccionController.text,
    'contact': contactoController.text,
    'description': descripcionController.text,
    'capacity': aforoController.text,
    'type': typeC ?? '',
    'isPrivate': isPrivateC,
    'isPayed': isPayedC,
    'lat': latitudC,
    'lng': longitudC,
    'date1': fecha1?.toIso8601String(),
    'date2': fecha2?.toIso8601String(),
    'hour1': firstTimeHour.hour,
    'min1': firstTimeHour.minute,
    'hour2': lastTimeHour.hour,
    'min2': lastTimeHour.minute,
    'bank': selectedBank ?? '',
    'phonePrefix': selectedPhonePrefix ?? '',
    'phoneNum': paymentPhoneNumberController.text,
    'ciType': selectedCIType ?? '',
    'ciNum': paymentCINumberController.text,
    'price': priceController.text,
  };
  await DraftManager.saveEventDraft(data);
  print("Draft saved to DraftManager");
}

Future<void> loadEventDraft() async {
  final data = await DraftManager.loadEventDraft();
  if (data == null) return;

  nombreEventoController.text = data['name'] ?? '';
  direccionController.text = data['address'] ?? '';
  contactoController.text = data['contact'] ?? '';
  descripcionController.text = data['description'] ?? '';
  aforoController.text = data['capacity'] ?? '';
  typeC = data['type'];
  if (typeC != null && typeC!.isEmpty) typeC = null;
  
  isPrivateC = data['isPrivate'] ?? false;
  isPayedC = data['isPayed'] ?? false;
  latitudC = data['lat'] ?? 10.0;
  longitudC = data['lng'] ?? -60.0;

  final d1 = data['date1'];
  if (d1 != null) {
    fecha1 = DateTime.parse(d1);
    fecha1C.text = d1.split('T')[0];
  }
  
  final d2 = data['date2'];
  if (d2 != null) {
    fecha2 = DateTime.parse(d2);
    fecha2C.text = d2.split('T')[0];
  }

  firstTimeHour = TimeOfDay(
    hour: data['hour1'] ?? 0,
    minute: data['min1'] ?? 0,
  );
  lastTimeHour = TimeOfDay(
    hour: data['hour2'] ?? 23,
    minute: data['min2'] ?? 59,
  );

  selectedBank = data['bank'];
  if (selectedBank != null && selectedBank!.isEmpty) selectedBank = null;
  
  selectedPhonePrefix = data['phonePrefix'];
  if (selectedPhonePrefix != null && selectedPhonePrefix!.isEmpty) selectedPhonePrefix = null;
  
  paymentPhoneNumberController.text = data['phoneNum'] ?? '';
  
  selectedCIType = data['ciType'];
  if (selectedCIType != null && selectedCIType!.isEmpty) selectedCIType = null;
  
  paymentCINumberController.text = data['ciNum'] ?? '';
  priceController.text = data['price'] ?? '';
  
  print("Draft loaded from DraftManager");
}

Future<void> clearEventDraft() async {
  await DraftManager.clearEventDraft();
}

// --- CONTROLADORES DE TEXTO GLOBALES ---
>>>>>>> origin/develop
final nombreEventoController = TextEditingController();
final direccionController = TextEditingController();
final contactoController = TextEditingController();
final descripcionController = TextEditingController();
final aforoController = TextEditingController();
<<<<<<< HEAD
final priceController = TextEditingController();

String? selectedType;
bool isPayed = false;
double latitudC = 10.4806;
double longitudC = -66.8983;

Map<String, dynamic> getCategoryData(String? type) {
  switch (type) {
    case 'Concierto':
      return {'icon': Icons.music_note_rounded, 'color': Colors.purple};
    case 'Teatro':
      return {'icon': Icons.theater_comedy_rounded, 'color': Colors.orange};
    case 'Cine':
      return {'icon': Icons.movie_filter_rounded, 'color': Colors.indigo};
    case 'Restaurante':
      return {'icon': Icons.restaurant_rounded, 'color': Colors.green};
    case 'Stand Up':
      return {
        'icon': Icons.mic_external_on_rounded,
        'color': Colors.deepOrange,
      };
    case 'Conferencia':
      return {
        'icon': Icons.record_voice_over_rounded,
        'color': Colors.indigoAccent,
      };
    case 'Fiesta':
      return {'icon': Icons.celebration_rounded, 'color': Colors.pinkAccent};
    case 'Otros':
      return {'icon': Icons.more_horiz_rounded, 'color': Colors.teal};
    default:
      return {'icon': Icons.help_outline_rounded, 'color': Colors.blueGrey};
  }
}

=======
final fecha1C = TextEditingController();
final fecha2C = TextEditingController();

// --- CONTROLADORES PARA DATOS DE PAGO ---
final paymentPhoneNumberController = TextEditingController();
final paymentCINumberController = TextEditingController();
final priceController = TextEditingController();

// --- ESTADO DE DROPDOWNS DE PAGO ---
String? selectedBank;
String? selectedPhonePrefix;
String? selectedCIType;

// --- LISTAS DE OPCIONES ---
const List<String> bankList = [
  '0102 - Banco De Venezuela',
  '0104 - Venezolano de Crédito',
  '0105 - Banco Mercantil',
  '0108 - Banco Provincial',
  '0114 - Banco Del Caribe',
  '0115 - Banco Exterior',
  '0128 - Banco Caroni',
  '0134 - Banesco Banco Universal',
  '0137 - Banco Sofitasa',
  '0138 - Banco Plaza',
  '0146 - Bangente',
  '0151 - BFC Banco Fondo Común',
  '0156 - 100% Banco',
  '0157 - Del Sur Banco Universal',
  '0163 - Banco Del Tesoro',
  '0166 - Banco Agrícola de Venezuela',
  '0168 - Bancrecer',
  '0169 - R4 Banco Microfinanciero',
  '0171 - Banco Activo',
  '0172 - Bancamiga',
  '0175 - Banco Digital De Los Trabajadores',
  '0177 - Banco De La Fuerza Armada Nacional Bolivariana',
  '0178 - N58 Banco Digital',
  '0191 - Banco Nacional Crédito',
];

const List<String> phonePrefixList = ['0412', '0414', '0416', '0424', '0426'];

const List<String> ciTypeList = [
  'V', // Venezolano
  'E', // Extranjero
  'P', // Pasaporte
  'J', // Jurídico
  'C', // Comuna
  'G', // Gubernamental
  'R', // Firma Personal
];

const Map<String, String> ciTypeLabels = {
  'V': 'Venezolano',
  'E': 'Extranjero',
  'P': 'Pasaporte',
  'J': 'Jurídico',
  'C': 'Comuna',
  'G': 'Gubernamental',
  'R': 'Firma Personal',
};

String? typeC;
String? stateC;
DateTime? fecha1;
DateTime? fecha2;
TimeOfDay firstTimeHour = TimeOfDay(hour: 0, minute: 0);
TimeOfDay lastTimeHour = TimeOfDay(hour: 23, minute: 59);
var idmod;
bool isPrivateC = false;
bool isPayedC = false;

double latitudC = 0.0;
double longitudC = 0.0;
bool isPrivate = false;

String? validateName(String? r) {
  if (r != '' || r!.isNotEmpty) {
    return 'Nombre existente';
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
    print('No es un valor numerico $e');
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

DateTime? validateDate(DateTime date1, DateTime date2) {
  if (date2.isBefore(date1)) {
    return null;
  } else {
    if (date1.isAtSameMomentAs(date2)) {
      if (firstTimeHour.hour < lastTimeHour.hour) {
        if (firstTimeHour.hour == lastTimeHour.hour &&
            firstTimeHour.minute >= lastTimeHour.minute) {
          return null;
        } else {
          return date2;
        }
      } else {
        return null;
      }
    } else {
      return date2;
    }
  }
}

Future<void> createEvent(BuildContext context) async {
  print(latitudC);
  print(longitudC);
  print(aforoController.text);
  print(contactoController.text);
  print(direccionController.text);
  print(fecha1);
  print(fecha2);
  print(firstTimeHour);
  print(lastTimeHour);
  print(nombreEventoController.text);
  print(descripcionController.text);
  print(typeC);
  if (nombreEventoController.text.isEmpty ||
      latitudC == 0.0 ||
      validateAforo(aforoController.text) == null ||
      validateName(contactoController.text) == null ||
      validateName(direccionController.text) == null ||
      validateDate(fecha1!, fecha2!) == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Por favor, ingresa el nombre y selecciona la ubicación en el mapa.',
        ),
        backgroundColor: Colors.red,
      ),
    );
  } else {
    try {
      final newEventRef = FirebaseFirestore.instance.collection('events').doc();
      await newEventRef.set({
  'id': newEventRef.id,
  'name': nombreEventoController.text,
  'address': direccionController.text,
  'contact': contactoController.text,
  'type': typeC,
  'state': 'Proximo',
  'id_organizer': FirebaseAuth.instance.currentUser!.uid,
  'description': descripcionController.text.trim(), // <--- Fix: Adiós código muerto
  'capacity': aforoController.text,
  'startDate': fecha1!.toIso8601String(),
  'endDate': fecha2!.toIso8601String(),
  'startTime': {'hour': firstTimeHour.hour, 'minute': firstTimeHour.minute},
  'endTime': {'hour': lastTimeHour.hour, 'minute': lastTimeHour.minute},
  'location': GeoPoint(latitudC, longitudC),
  'createdAt': FieldValue.serverTimestamp(),
  'stars': 0,
  'total_review': 0,
  'isPrivate': isPrivateC, 
  'isPayed': isPayedC,
});
      if (isPayedC) {
        await newEventRef.update({
          'paymentInfo': {
            'bank': selectedBank ?? '',
            'phone':
                selectedPhonePrefix != null &&
                    paymentPhoneNumberController.text.isNotEmpty
                ? '$selectedPhonePrefix-${paymentPhoneNumberController.text}'
                : '',
            'ci':
                selectedCIType != null &&
                    paymentCINumberController.text.isNotEmpty
                ? '$selectedCIType-${paymentCINumberController.text}'
                : '',
            'price': double.tryParse(priceController.text) ?? 0.0,
          },
        });
      }
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Evento creado y ubicado en el mapa con éxito!'),
          backgroundColor: Colors.green,
        ),
      );

      clearAllFields();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear: $e')));
    }
  }
}

// --- FUNCIÓN PARA LIMPIAR EL FORMULARIO ---
>>>>>>> origin/develop
void clearAllFields() {
  nombreEventoController.clear();
  direccionController.clear();
  contactoController.clear();
  descripcionController.clear();
  aforoController.clear();
<<<<<<< HEAD
  priceController.clear();
  selectedType = null;
  isPayed = false;
}

Future<void> createEvent(BuildContext context) async {
  if (nombreEventoController.text.isEmpty || selectedType == null) return;
  try {
    final ref = FirebaseFirestore.instance.collection('events').doc();
    await ref.set({
      'id': ref.id,
      'name': nombreEventoController.text,
      'address': direccionController.text,
      'contact': contactoController.text,
      'description': descripcionController.text,
      'capacity': aforoController.text,
      'type': selectedType,
      'isPayed': isPayed,
      'price': isPayed ? (double.tryParse(priceController.text) ?? 0.0) : 0.0,
      'location': GeoPoint(latitudC, longitudC),
      'id_organizer': FirebaseAuth.instance.currentUser?.uid,
      'stars': 0.0,
      'total_review': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!context.mounted) return; // FIX: Async Gap
    clearAllFields();
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('¡Evento publicado!')));
  } catch (e) {
    debugPrint(e.toString());
  }
}

Stream<List<Map<String, dynamic>>> chargeFilteredEvents({
  required String category,
  required String search,
}) {
  return FirebaseFirestore.instance.collection('events').snapshots().map((
    snap,
  ) {
    return snap.docs
        .map((doc) {
          final d = doc.data(); // FIX: Quitamos el cast innecesario
          return {...d, 'id': doc.id};
        })
        .where((item) {
          final s = search.toLowerCase();
          if (category != 'Todos' && item['type'] != category) return false;
          return (item['name'] ?? '').toString().toLowerCase().contains(s) ||
              item['id'].toString().toLowerCase() == s;
        })
        .toList();
  });
}

Future<List<Map<String, dynamic>>> chargeEvents() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  final snap = await FirebaseFirestore.instance
      .collection('events')
      .where('id_organizer', isEqualTo: user.uid)
      .get();
  return snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
}

// Stubs para evitar errores
=======
  isPrivate = false;
  fecha1C.clear();
  fecha2C.clear();
  paymentPhoneNumberController.clear();
  paymentCINumberController.clear();
  priceController.clear();
  selectedBank = null;
  selectedPhonePrefix = null;
  selectedCIType = null;
  typeC = null;
  isPrivateC = false;
  latitudC = 10.0;
  longitudC = -60.0;
  firstTimeHour = TimeOfDay(hour: 0, minute: 0);
  lastTimeHour = TimeOfDay(hour: 23, minute: 59);
  clearEventDraft();
}

// --- FUNCIÓN PARA CARGAR EVENTOS (Para el Panel de Control) ---
Future<List<Map<String, dynamic>>> chargeEvents() async {
  List<Map<String, dynamic>> eventos = [];

  try {
    print(FirebaseAuth.instance.currentUser!.uid);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where(
          'id_organizer',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      eventos.add(data);
    }
  } catch (e) {
    print("$e");
  }

  return eventos;
}

Future<void> cargarDatosEvento(String idDocumento) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(idDocumento)
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      nombreEventoController.text = data['name'] ?? '';
      direccionController.text = data['address'] ?? '';
      contactoController.text = data['contact'] ?? '';
      descripcionController.text = data['description'] ?? '';
      aforoController.text = data['capacity'] ?? '';
      isPrivateC = data['isPrivate'] ?? false;
      stateC = data['state'] ?? 'Proximo';
      final pi = data['paymentInfo'] as Map<String, dynamic>?;
      if (pi != null) {
        // Bank dropdown
        final bankStr = pi['bank'] ?? '';
        if (bankStr.isNotEmpty && bankList.contains(bankStr)) {
          selectedBank = bankStr;
        }
        // Phone: split "prefix-number"
        final phoneStr = pi['phone'] ?? '';
        if (phoneStr.contains('-')) {
          final parts = phoneStr.split('-');
          selectedPhonePrefix = parts[0];
          paymentPhoneNumberController.text = parts.sublist(1).join('-');
        }
        // CI: split "type-number"
        final ciStr = pi['ci'] ?? '';
        if (ciStr.contains('-')) {
          final parts = ciStr.split('-');
          selectedCIType = parts[0];
          paymentCINumberController.text = parts.sublist(1).join('-');
        }
        priceController.text = (pi['price'] ?? 0.0).toString();
      }
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
    if (nombreEventoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa el nombre del evento.'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (validateName(contactoController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un contacto válido.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } else {
    try {
      var newEventRef = FirebaseFirestore.instance.collection('events').doc(id);
      var docSnapshot = await newEventRef.get();

      if (docSnapshot.exists) {

        var pagado = docSnapshot['isPayed'] ?? false;

        await newEventRef.update({
          'name': nombreEventoController.text,
          'address': direccionController.text,
          'contact': contactoController.text,
          'state': stateC ?? 'Próximo',
          'description': descripcionController.text,
          'capacity': aforoController.text,
          'isPrivate': isPrivateC,
        });
        if (pagado) {
          await newEventRef.update({
            'paymentInfo': {
              'bank': selectedBank ?? '',
              'phone':
                  selectedPhonePrefix != null &&
                      paymentPhoneNumberController.text.isNotEmpty
                  ? '$selectedPhonePrefix-${paymentPhoneNumberController.text}'
                  : '',
              'ci':
                  selectedCIType != null &&
                      paymentCINumberController.text.isNotEmpty
                  ? '$selectedCIType-${paymentCINumberController.text}'
                  : '',
              'price': double.tryParse(priceController.text) ?? 0.0,
            },
          });
        }

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Evento modificado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print("El documento con id $id no existe");
      }

      // LIMPIAR TODOS LOS CAMPOS
      clearAllFields();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al modificar: $e')));
    }
  }
}

Future<void> updateEventStatusOnLogin() async {
  final now = DateTime.now();
  final eventsRef = FirebaseFirestore.instance.collection('events');

  try {
    final snapshot = await eventsRef
        .where('state', whereIn: ['Ocurriendo', 'Proximo'])
        .get();

    if (snapshot.docs.isEmpty) return;

    WriteBatch batch = FirebaseFirestore.instance.batch();
    bool hasChanges = false;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['startDate'] == null) continue;

      // Conversión de fecha (ajusta si usas Timestamp o String)
      DateTime startDate = DateTime.parse(data['startDate']);
      final difference = startDate.difference(now).inDays;
      String currentState = data['state'];
      String? newState;
      if (difference < 0 && currentState != 'Ocurriendo') {
        newState = 'Ocurriendo';
      }

      if (newState != null) {
        batch.update(doc.reference, {'state': newState});
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await batch.commit();
      print("Sincronización de estados completada tras login.");
    }
  } catch (e) {
    print("Error sincronizando estados: $e");
  }
}

// --- COMENTARIOS Y VALORACIONES ---
>>>>>>> origin/develop
Future<void> agregarComentario({
  required String eventoId,
  required String texto,
  required String usuarioNombre,
  required String usuarioUid,
  int? rating,
<<<<<<< HEAD
}) async {}
Stream<List<Map<String, dynamic>>> obtenerComentariosStream(String id) =>
    Stream.value([]);
Future<void> deleteEvent(String id) async {
  await FirebaseFirestore.instance.collection('events').doc(id).delete();
}

Future<void> updateEventStatusOnLogin() async {}
Future<void> modifyEvent(BuildContext context, String id) async {
  if (context.mounted) Navigator.pop(context);
}

Future<void> cargarDatosEvento(String id) async {}
Future<void> agregarValoracion({
  required String eventoId,
  required int rating,
  required String usuarioUid,
}) async {}
=======
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
      .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
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

    final Map<String, dynamic> eventData = eventSnap.data() ?? {};
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

//ESTOS SON LOS CAMBIOS DE JAVIER

Map<String, dynamic> userPreferredFilters = {
  'category': 'Todos',
  'tags': <String>[],
};

void saveFiltersLocally(String category, List<String> tags) {
  userPreferredFilters['category'] = category;
  userPreferredFilters['tags'] = List<String>.from(tags);
}

String formatTimeFromMap(dynamic timeData) {
  if (timeData == null || timeData is! Map) return "N/A";
  final hour = timeData['hour']?.toString().padLeft(2, '0') ?? "00";
  final minute = timeData['minute']?.toString().padLeft(2, '0') ?? "00";
  return "$hour:$minute";
}

String getBochincheLoadingMessage() {
  final messages = [
    "Afinando instrumentos...",
    "Enfriando bebidas...",
    "Preparando el VIP...",
    "Ubicando la tarima...",
  ];
  return messages[Random().nextInt(messages.length)];
}

Stream<List<Map<String, dynamic>>> chargeFilteredEvents({
  required SearchMode mode,
  required String category,
  required String? search,
  DateTime? date,
}) {
  final safeSearch = search ?? '';
  final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

  // --- CASO 1: BÚSQUEDA DE BOCHINCHEROS (USUARIOS) ---
  if (mode == SearchMode.bochincheros) {
    if (category == 'Seguidos') {
      if (currentUserUid == null) return Stream.value([]);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .snapshots()
          .asyncMap((userDoc) async {
            List<dynamic> followingIds = userDoc.data()?['following'] ?? [];
            if (followingIds.isEmpty) return [];

            // Traemos todos para filtrar localmente y saltar el límite de 10 de Firestore
            QuerySnapshot allUsersSnap = await FirebaseFirestore.instance
                .collection('users')
                .get();

            return allUsersSnap.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .where((userData) {
                  final String id = userData['uid'] ?? '';
                  final String nombre = (userData['nombre'] ?? '')
                      .toString()
                      .toLowerCase();
                  return followingIds.contains(id) &&
                      nombre.contains(safeSearch.toLowerCase());
                })
                .toList();
          });
    }

    // Búsqueda normal de usuarios
    return FirebaseFirestore.instance
        .collection('users')
        .where('nombre', isGreaterThanOrEqualTo: safeSearch)
        .where('nombre', isLessThanOrEqualTo: '$safeSearch\uf8ff')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => doc.data())
              .toList(),
        );
  }

  // --- CASO 2: BÚSQUEDA DE EVENTOS ---

  // A. Lógica especial para Categoría "Seguidos"
  if (category == 'Seguidos') {
    if (currentUserUid == null) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .snapshots()
        .asyncMap((userDoc) async {
          List<dynamic> followingIds = userDoc.data()?['following'] ?? [];
          if (followingIds.isEmpty) return [];

          QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
              .collection('events')
              .where('isPrivate', isEqualTo: false)
              .get();

          return eventSnapshot.docs
              .map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return data;
              })
              .where((event) {
                final String organizerId = event['id_organizer'] ?? '';
                final String eventName = (event['name'] ?? '')
                    .toString()
                    .toLowerCase();
                return followingIds.contains(organizerId) &&
                    eventName.contains(safeSearch.toLowerCase());
              })
              .toList();
        });
  }
  Query query = FirebaseFirestore.instance.collection('events');
  // B. Lógica para Eventos Públicos, Privados y otras Categorías
  if (mode == SearchMode.privados) {
    if (safeSearch.isEmpty) return Stream.value([]);

    // 1. MODO PRIVADO: Buscamos por el ID del documento usando FieldPath.documentId
    // Hacemos el return directamente aquí para evitar el filtro por nombre de abajo
    return FirebaseFirestore.instance
        .collection('events')
        .where(
          FieldPath.documentId,
          isEqualTo: safeSearch,
        ) // Busca por el ID del doc
        .where('isPrivate', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  } else {
    // 2. MODO PÚBLICO: Construimos la query
    query = query.where('isPrivate', isEqualTo: false);

    if (category != 'Todos') {
      query = query.where('type', isEqualTo: category);
    }

    // Retornamos el stream de públicos con tu filtro local por nombre
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          })
          .where((event) {
            // Si no hay búsqueda, pasan todos
            if (safeSearch.isEmpty) return true;

            // Filtro local insensible a mayúsculas/minúsculas
            String name = (event['name'] ?? '').toString().toLowerCase();
            return name.contains(safeSearch.toLowerCase());
          })
          .toList();
    });
  }
}

Future<List<Map<String, dynamic>>> getUserPredictions(String input) async {
  if (input.isEmpty) return [];
  final snap = await FirebaseFirestore.instance
      .collection('users')
      .where('nombre', isGreaterThanOrEqualTo: input)
      .where('nombre', isLessThanOrEqualTo: '$input\uf8ff')
      .limit(5)
      .get();

  return snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
}

// Función para sugerir Eventos
Future<List<Map<String, dynamic>>> getEventPredictions(String input) async {
  if (input.isEmpty) return [];
  final snap = await FirebaseFirestore.instance
      .collection('events')
      .where('isPrivate', isEqualTo: false)
      .where('name', isGreaterThanOrEqualTo: input)
      .where('name', isLessThanOrEqualTo: '$input\uf8ff')
      .limit(5)
      .get();

  return snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
}

Future<void> registrarUsuarioEnEvento(BuildContext context, Map<String, dynamic> data, String eventoId) async {
  final user = FirebaseAuth.instance.currentUser;

  // 1. Verificamos que el usuario esté logueado
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debes iniciar sesión para reservar tu entrada.')),
    );
    return;
  }

  try {
    // Referencias a los documentos en Firebase
    DocumentReference eventRef = FirebaseFirestore.instance.collection('events').doc(eventoId);
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Usamos un WriteBatch para hacer varios cambios al mismo tiempo y que no falle a la mitad
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // 2. Actualizamos el evento: Sumamos 1 a las entradas vendidas/reservadas y guardamos el ID del usuario
    batch.update(eventRef, {
      'ticketsSold': FieldValue.increment(1),
      'attendees': FieldValue.arrayUnion([user.uid]), // Asumiendo que guardas un arreglo de asistentes
    });

    // 3. (Opcional) Actualizamos al usuario: Guardamos el ID del evento en su perfil para que pueda ver sus reservas
    batch.set(userRef, {
      'mis_reservas': FieldValue.arrayUnion([eventoId]),
    }, SetOptions(merge: true)); // Usamos merge por si el documento del usuario no tiene este campo aún

    // Ejecutamos todo de un golpe
    await batch.commit();

    // 4. Le avisamos al usuario que todo salió bien
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Entrada reservada con éxito! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    }

  } catch (e) {
    print("Error al reservar la entrada: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hubo un problema al reservar. Intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
>>>>>>> origin/develop
