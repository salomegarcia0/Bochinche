import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Variables de estado para los formularios
String? reportId;
String? eventToReport;
String? userToReport;

// Motivos de reporte (Eventos)
bool locationError = false;
bool montoError = false;
bool incumplimientoLey = false;
bool infrastructureFail = false;
bool otherError = false;

// Motivos de reporte (Usuarios)
bool isViolentDiscourse = false;
bool isInappropriateContent = false;
bool isSpam = false;
bool isHarassment = false;
bool isHate = false;

TextEditingController reportDetailsController = TextEditingController();
TextEditingController feedbackController = TextEditingController();

// --- LÓGICA DE ENVÍO DE REPORTES ---

Future<void> reportEvent(BuildContext context) async {
  List<String> selectedReasons = [];
  if (locationError) selectedReasons.add('Localización Incorrecta');
  if (montoError) selectedReasons.add('Monto Incorrecto');
  if (incumplimientoLey) selectedReasons.add('Incumplimiento de Leyes');
  if (infrastructureFail) selectedReasons.add('Fallas de infraestructura');
  if (otherError) selectedReasons.add('Otro: ${reportDetailsController.text}');

  if (selectedReasons.isEmpty) return;

  try {
    final ref = FirebaseFirestore.instance.collection('reports').doc();
    await ref.set({
      'reportId': ref.id,
      'eventId': eventToReport,
      'reporterId': FirebaseAuth.instance.currentUser?.uid,
      'reason': selectedReasons,
      'status': 'Pendiente',
      'feedback': 'Ninguno',
      'timestamp': FieldValue.serverTimestamp(),
      'evento': true,
    });
  } catch (e) {
    debugPrint('Error: $e');
  }
}

Future<void> reportUser(BuildContext context) async {
  List<String> selectedReasons = [];
  if (isHate) selectedReasons.add('Odio');
  if (isHarassment) selectedReasons.add('Abuso y acoso');
  if (isViolentDiscourse) selectedReasons.add('Discurso violento');
  if (isSpam) selectedReasons.add('Spam');
  if (isInappropriateContent) selectedReasons.add('Comportamientos ilegales');

  if (selectedReasons.isEmpty) return;

  try {
    final ref = FirebaseFirestore.instance.collection('reports').doc();
    await ref.set({
      'reportId': ref.id,
      'userId': userToReport,
      'reporterId': FirebaseAuth.instance.currentUser?.uid,
      'reason': selectedReasons,
      'status': 'Pendiente',
      'feedback': 'Ninguno',
      'timestamp': FieldValue.serverTimestamp(),
      'evento': false,
    });
  } catch (e) {
    debugPrint('Error: $e');
  }
}

// --- LÓGICA DE ADMINISTRACIÓN ---

Future<void> updateReportStatus(String reportId, String? eventId) async {
  await FirebaseFirestore.instance.collection('reports').doc(reportId).update({
    'status': 'Resuelto',
    'feedback': feedbackController.text.trim(),
  });
  if (eventId != null) {
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
  }
  feedbackController.clear();
}

Future<void> updateReportStatusUser(String reportId, String? userId) async {
  await FirebaseFirestore.instance.collection('reports').doc(reportId).update({
    'status': 'Resuelto',
    'feedback': feedbackController.text.trim(),
  });
  if (userId != null) {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'banned': true,
    });
  }
  feedbackController.clear();
}

Future<void> ignoreReport(String reportId) async {
  await FirebaseFirestore.instance.collection('reports').doc(reportId).update({
    'status': 'Resuelto',
    'feedback': 'Ignorado: ${feedbackController.text.trim()}',
  });
  feedbackController.clear();
}

void setReportEventsFalse() {
  locationError = montoError = incumplimientoLey = infrastructureFail =
      otherError = false;
  reportDetailsController.clear();
}

void setReportUserFalse() {
  isHate = isHarassment = isSpam = isViolentDiscourse = isInappropriateContent =
      false;
}
