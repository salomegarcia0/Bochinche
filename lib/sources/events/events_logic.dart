import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SearchMode { eventos, privados, bochincheros }

String? eventToReport;
String? userToReport;
String idmod = "";

final nombreEventoController = TextEditingController();
final direccionController = TextEditingController();
final contactoController = TextEditingController();
final descripcionController = TextEditingController();
final aforoController = TextEditingController();
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

void clearAllFields() {
  nombreEventoController.clear();
  direccionController.clear();
  contactoController.clear();
  descripcionController.clear();
  aforoController.clear();
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
Future<void> agregarComentario({
  required String eventoId,
  required String texto,
  required String usuarioNombre,
  required String usuarioUid,
  int? rating,
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
