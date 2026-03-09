import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/core/utils/draft_manager.dart';

enum SearchMode { eventos, privados, bochincheros }

// --- VARIABLES GLOBALES ---
String? eventToReport;
String? userToReport;
String? idmod;

// --- CONTROLADORES DE FORMULARIO ---
final nombreEventoController = TextEditingController();
final direccionController = TextEditingController();
final contactoController = TextEditingController();
final descripcionController = TextEditingController();
final aforoController = TextEditingController();
final fecha1C = TextEditingController();
final fecha2C = TextEditingController();
final paymentPhoneNumberController = TextEditingController();
final paymentCINumberController = TextEditingController();
final priceController = TextEditingController();

// --- ESTADO ---
String? selectedType;
String? typeC;
String? stateC;
bool isPrivateC = false;
bool isPayedC = false;
double latitudC = 10.4806;
double longitudC = -66.8983;

DateTime? fecha1;
DateTime? fecha2;
TimeOfDay firstTimeHour = const TimeOfDay(hour: 0, minute: 0);
TimeOfDay lastTimeHour = const TimeOfDay(hour: 23, minute: 59);

// --- LISTAS DE APOYO PARA CREACIÓN ---
String? selectedBank;
String? selectedPhonePrefix;
String? selectedCIType;

const List<String> bankList = [
  '0102 - Banco De Venezuela',
  '0104 - Venezolano de Crédito',
  '0105 - Banco Mercantil',
  '0108 - Banco Provincial',
  '0114 - Banco Del Caribe',
  '0134 - Banesco',
  '0172 - Bancamiga',
  '0191 - BNC',
];
const List<String> phonePrefixList = ['0412', '0414', '0416', '0424', '0426'];
const List<String> ciTypeList = ['V', 'E', 'P', 'J', 'G'];

// --- MAPEO DE ICONOS Y COLORES (Pines distintivos) ---
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
    case 'Fiesta':
      return {'icon': Icons.celebration_rounded, 'color': Colors.pinkAccent};
    case 'Conferencia':
      return {'icon': Icons.record_voice_over_rounded, 'color': Colors.blue};
    default:
      return {'icon': Icons.event_available_rounded, 'color': Colors.blueGrey};
  }
}

// --- LÓGICA DE FIREBASE ---
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
    final ref = FirebaseFirestore.instance.collection('events').doc();
    await ref.set({
      'id': ref.id,
      'name': nombreEventoController.text,
      'address': direccionController.text,
      'contact': contactoController.text,
      'description': descripcionController.text,
      'type': selectedType ?? 'Otros',
      'location': GeoPoint(latitudC, longitudC),
      'id_organizer': FirebaseAuth.instance.currentUser?.uid,
      'state': 'Proximo',
      'isPayed': isPayedC,
      'isPrivate': isPrivateC,
      'ticketsSold': 0,
      'capacity': int.tryParse(aforoController.text) ?? 100,
      'startDate': fecha1?.toIso8601String(),
      'endDate': fecha2?.toIso8601String(),
      'startTime': {'hour': firstTimeHour.hour, 'minute': firstTimeHour.minute},
      'endTime': {'hour': lastTimeHour.hour, 'minute': lastTimeHour.minute},
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
  contactoController.clear();
  descripcionController.clear();
  aforoController.clear();
  fecha1C.clear();
  fecha2C.clear();
  DraftManager.clearEventDraft();
}

Stream<List<Map<String, dynamic>>> chargeFilteredEvents({
  required SearchMode mode,
  required String category,
  required String? search,
}) {
  Query query = FirebaseFirestore.instance.collection('events');
  if (category != 'Todos') query = query.where('type', isEqualTo: category);
  return query.snapshots().map(
    (snap) => snap.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList(),
  );
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
      .orderBy('fecha', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()).toList());
}
