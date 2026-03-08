import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/core/utils/draft_manager.dart';

enum SearchMode { eventos, privados, bochincheros }

String? eventToReport;
String? userToReport;

// Controladores globales
final nombreEventoController = TextEditingController();
final direccionController = TextEditingController();
final contactoController = TextEditingController();
final descripcionController = TextEditingController();
final aforoController = TextEditingController();
final priceController = TextEditingController();

String? selectedType;
bool isPayedC = false;
double latitudC = 10.4806;
double longitudC = -66.8983;
String? typeC;

Future<void> updateEventStatusOnLogin() async {
  final now = DateTime.now();
  try {
    final snap = await FirebaseFirestore.instance.collection('events').get();
    for (var doc in snap.docs) {
      final data = doc.data();
      if (data['startDate'] == null) continue;
      DateTime start = DateTime.parse(data['startDate']);
      if (start.isBefore(now) && data['state'] == 'Proximo') {
        await doc.reference.update({'state': 'Ocurriendo'});
      }
    }
  } catch (e) {
    debugPrint("Error: $e");
  }
}

Future<void> createEvent(BuildContext context) async {
  if (nombreEventoController.text.isEmpty) return;
  try {
    await FirebaseFirestore.instance.collection('events').add({
      'name': nombreEventoController.text,
      'type': selectedType ?? 'Otros',
      'location': GeoPoint(latitudC, longitudC),
      'id_organizer': FirebaseAuth.instance.currentUser?.uid,
      'state': 'Proximo',
      'createdAt': FieldValue.serverTimestamp(),
    });
    clearAllFields();
    if (context.mounted) Navigator.pop(context);
  } catch (e) {
    debugPrint(e.toString());
  }
}

void registrarUsuarioEnEvento(
  BuildContext context,
  Map<String, dynamic> data,
  String eventoId,
) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('tickets')
      .doc(eventoId)
      .set({
        'eventId': eventoId,
        'eventName': data['name'],
        'boughtAt': FieldValue.serverTimestamp(),
      });
}

void clearAllFields() {
  nombreEventoController.clear();
  direccionController.clear();
  DraftManager.clearEventDraft();
}

Map<String, dynamic> getCategoryData(String? type) {
  switch (type) {
    case 'Concierto':
      return {'icon': Icons.music_note, 'color': Colors.purple};
    case 'Fiesta':
      return {'icon': Icons.celebration, 'color': Colors.pink};
    default:
      return {'icon': Icons.event, 'color': Colors.blueGrey};
  }
}

Stream<List<Map<String, dynamic>>> chargeFilteredEvents({
  required SearchMode mode,
  required String category,
  required String? search,
}) {
  return FirebaseFirestore.instance.collection('events').snapshots().map((
    snap,
  ) {
    return snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  });
}

Future<void> saveEventDraft() async {}
Future<void> loadEventDraft() async {}

String getBochincheLoadingMessage() => "Afinando instrumentos...";
Future<void> agregarComentario({
  required String eventoId,
  required String texto,
  required String usuarioNombre,
  required String usuarioUid,
}) async {
  await FirebaseFirestore.instance
      .collection('events')
      .doc(eventoId)
      .collection('comments')
      .add({
        'texto': texto,
        'nombre': usuarioNombre,
        'uid': usuarioUid,
        'fecha': FieldValue.serverTimestamp(),
      });
}

Stream<List<Map<String, dynamic>>> obtenerComentariosStream(String id) {
  return FirebaseFirestore.instance
      .collection('events')
      .doc(id)
      .collection('comments')
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()).toList());
}
