import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

String? reportId;
String? eventToReport;
String? userToReport;
bool? locationError = false;
bool? montoError = false;
bool? incumplimientoLey = false;
bool? infrastructureFail = false;
bool? otherError = false;
TextEditingController reportDetailsController = TextEditingController();
TextEditingController feedbackController = TextEditingController();

Future<void> reportEvent(BuildContext context) async {
  List<String> selectedReasons = [];
  String reportDetails = ": ${reportDetailsController.text.trim()}";
  if (locationError == false &&
      montoError == false &&
      incumplimientoLey == false &&
      infrastructureFail == false &&
      otherError == false) {
    print('No se ha seleccionado ningún error para reportar.');
  } else {
    print('Reporte enviado:');
    print('Evento ID: $eventToReport');
    print('Usuario ID: $userToReport');
    print('Errores:');
    if (locationError == true) selectedReasons.add('Localización Incorrecta');
    if (montoError == true) selectedReasons.add('Monto Incorrecto');
    if (incumplimientoLey == true)
      selectedReasons.add('Incumplimiento de Leyes o Normativas Locales');
    if (infrastructureFail == true)
      selectedReasons.add('Fallas de infraestructura');
    if (otherError == true && reportDetailsController.text.trim().isNotEmpty) {
      selectedReasons.add('Otro error${reportDetails}');
    } else {
      if (otherError == true && reportDetailsController.text.trim().isEmpty) {
        selectedReasons.add('Otro error no especificado');
      }
    }

    try {
      final newReportRef = FirebaseFirestore.instance
          .collection('reports')
          .doc();
      await newReportRef.set({
        'reportId': newReportRef.id,
        'eventId': eventToReport,
        'reporterId': FirebaseAuth.instance.currentUser?.uid,
        'reason': selectedReasons,
        'status': 'Pendiente',
        'feedback': 'Ninguno',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al enviar el reporte: $e');
    }
  }
}

Future<List<Map<String, dynamic>>> chargeReportsUser() async {
  List<Map<String, dynamic>> reportes = [];

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('reporterId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      reportes.add(data);
    }
  } catch (e) {
    print("Error cargando reportes: $e");
  }

  return reportes;
}

Future<List<Map<String, dynamic>>> chargeReportsAdmin() async {
  List<Map<String, dynamic>> reportes = [];

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('status', isEqualTo: 'Pendiente')
        .get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      reportes.add(data);
    }
  } catch (e) {
    print("Error cargando reportes: $e");
  }

  return reportes;
}

Future<void> updateReportStatus(String reportId) async {
  try {
    await FirebaseFirestore.instance.collection('reports').doc(reportId).update(
      {'status': 'Resuelto', 'feedback': feedbackController.text.trim()},
    );
    print('Reporte $reportId actualizado a estado: Resuelto');
    feedbackController.text = '';
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('reportId', isEqualTo: reportId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
      final evento = data['eventId'];
      await FirebaseFirestore.instance
          .collection('events')
          .doc(evento)
          .delete();
    } else {
      print("No report found");
    }
  } catch (e) {
    print('Error al actualizar el reporte: $e');
  }
}
