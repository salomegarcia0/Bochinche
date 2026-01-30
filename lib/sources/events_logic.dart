/*
  Los datos que tienen DK son datos que aun no se pueden obtener
  id_organizer: no existe aun register ni login
  longitude: no esta el mapa para poner los pines en la creacion
  latitude: no esta el mapa para poner los pines en la creacion
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

TextEditingController fecha1C = TextEditingController();
TextEditingController fecha2C = TextEditingController();
TextEditingController nombreEventoController = TextEditingController();
TextEditingController descripcionController = TextEditingController();
TextEditingController direccionController = TextEditingController();
TextEditingController contactoController = TextEditingController();
TextEditingController aforoController = TextEditingController();
DateTime? fecha1;
DateTime? fecha2;
TimeOfDay firtTimeHour = TimeOfDay.now();
TimeOfDay lastTimeHour = TimeOfDay.now();
String? typeC;

Future<void> createEvent(BuildContext context) async {
  try {
    final documento = FirebaseFirestore.instance.collection("events").doc();
    await documento.set({
      'id': documento.id,
      'id_organizer': 'DK',
      'name': nombreEventoController.text,
      'contact': contactoController.text,
      'direction': direccionController.text,
      'ini_date': fecha1!.toIso8601String(),
      'fin_date': fecha2!.toIso8601String(),
      'quantity': aforoController.text,
      'type': typeC,
      'description': descripcionController.text,
      'status': 'Proximo',
      'ini_hour': {'hour': firtTimeHour.hour, 'minute': firtTimeHour.minute},
      'fin_hour': {'hour': lastTimeHour.hour, 'minute': lastTimeHour.minute},
      'total_stars': 0,
      'number_ratings': 0,
      'longitude': 'DK',
      'latitude': 'DK',
    });
    print(documento.id);
  } catch (e) {
    print("Error $e");
  }
}

Future<List> chargeEvents() async {
  final List lista;
  QuerySnapshot snap = await FirebaseFirestore.instance
      .collection('events')
      .get();
  lista = snap.docs.map((doc) {
    Map<String, dynamic> evento = doc.data() as Map<String, dynamic>;
    return evento;
  }).toList();
  return lista;
}

void dispose() {
  fecha1C.clear();
  fecha2C.clear();
  nombreEventoController.clear();
  descripcionController.clear();
  direccionController.clear();
  contactoController.clear();
  aforoController.clear();
}
