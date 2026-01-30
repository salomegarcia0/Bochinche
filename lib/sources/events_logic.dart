import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

TextEditingController fecha1 = TextEditingController();
TextEditingController fecha2 = TextEditingController();
TextEditingController nombreEventoController = TextEditingController();
TextEditingController descripcionController = TextEditingController();
TextEditingController direccionController = TextEditingController();
TextEditingController contactoController = TextEditingController();
TextEditingController aforoController = TextEditingController();
String? typeC;

Future<void> createEvent(BuildContext context) async {
  try {
    final documento = FirebaseFirestore.instance.collection("events").doc();
    await documento.set({
      'id': documento.id,
      'name': nombreEventoController.text,
      'direction': direccionController.text,
      'ini_date': fecha1.toString(),
      'fin_date': fecha2.toString(),
      'quantity': aforoController.text,
      'type': typeC,
      'description': descripcionController.text,
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
  fecha1.clear();
  fecha2.clear();
  nombreEventoController.clear();
  descripcionController.clear();
  direccionController.clear();
  contactoController.clear();
  aforoController.clear();
}
