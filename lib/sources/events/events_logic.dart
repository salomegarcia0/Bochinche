import 'dart:math';

import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- CONTROLADORES DE TEXTO GLOBALES ---
final nombreEventoController = TextEditingController();
final direccionController = TextEditingController();
final contactoController = TextEditingController();
final descripcionController = TextEditingController();
final aforoController = TextEditingController();
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
TimeOfDay firtTimeHour = TimeOfDay(hour: 0, minute: 0);
TimeOfDay lastTimeHour = TimeOfDay(hour: 23, minute: 59);
var idmod;
bool isPrivateC = false;

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
      if (firtTimeHour.hour < lastTimeHour.hour) {
        if (firtTimeHour.hour == lastTimeHour.hour &&
            firtTimeHour.minute >= lastTimeHour.minute) {
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
  print(firtTimeHour);
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
        'description': descripcionController.text != null
            ? descripcionController.text
            : '',
        'capacity': aforoController.text,
        'isPrivate': isPrivate,
        'startDate': fecha1!.toIso8601String(),
        'endDate': fecha2!.toIso8601String(),
        'startTime': {'hour': firtTimeHour.hour, 'minute': firtTimeHour.minute},
        'endTime': {'hour': lastTimeHour.hour, 'minute': lastTimeHour.minute},
        'location': GeoPoint(latitudC, longitudC),
        'createdAt': FieldValue.serverTimestamp(),
        'stars': 0,
        'total_review': 0,
        'isPrivate': isPrivateC,
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
void clearAllFields() {
  nombreEventoController.clear();
  direccionController.clear();
  contactoController.clear();
  descripcionController.clear();
  aforoController.clear();
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
  firtTimeHour = TimeOfDay(hour: 0, minute: 0);
  lastTimeHour = TimeOfDay(hour: 23, minute: 59);
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, ingresa la información completa.'),
        backgroundColor: Colors.red,
      ),
    );
  } else {
    try {
      final newEventRef = FirebaseFirestore.instance
          .collection('events')
          .doc(id);

      await newEventRef.update({
        'name': nombreEventoController.text,
        'address': direccionController.text,
        'contact': contactoController.text,
        'state': stateC ?? 'Próximo',
        'description': descripcionController.text,
        'capacity': aforoController.text,
        'isPrivate': isPrivateC,
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
