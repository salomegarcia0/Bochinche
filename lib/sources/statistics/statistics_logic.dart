import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> obtenerRankingConNombresReales() async {
  try {
    QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .get();

    Map<String, int> conteoPorId = {};

    for (var doc in eventsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String? userId = data['id_organizer'];

      if (userId != null) {
        conteoPorId[userId] = (conteoPorId[userId] ?? 0) + 1;
      }
    }

    List<Map<String, dynamic>> rankingFinal = [];

    for (String userId in conteoPorId.keys) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      String nombreReal = 'Usuario Desconocido';

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        nombreReal = userData['nombre'] ?? 'Sin Nombre';
      }

      rankingFinal.add({
        'nombre': nombreReal,
        'totalEventos': conteoPorId[userId],
      });
    }

    rankingFinal.sort((a, b) => b['totalEventos'].compareTo(a['totalEventos']));

    return rankingFinal;
  } catch (e) {
    print("Error en el ranking: $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> obtenerTop5Eventos() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('events')
      .get();

  List<Map<String, dynamic>> eventosConConteo = querySnapshot.docs.map((doc) {
    List<dynamic> asistentes = doc.data().containsKey('attendees')
        ? doc['attendees']
        : [];

    return {
      'nombre': doc['name'] ?? 'Sin nombre',
      'cantidad': asistentes.length,
    };
  }).toList();

  eventosConConteo.sort((a, b) => b['cantidad'].compareTo(a['cantidad']));

  // Retornar solo los 5 mejores
  return eventosConConteo.take(5).toList();
}

Future<String> obtenerEventosTotales() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('events')
      .get();
  return querySnapshot.docs.length.toString();
}

Future<String> obtenerEventosPrivados() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('events')
      .where('isPrivate', isEqualTo: true)
      .get();

  return querySnapshot.docs.length.toString();
}

Future<String> obtenerEventosActivos() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('events')
      .where('state', isEqualTo: 'Ocurriendo')
      .get();

  return querySnapshot.docs.length.toString();
}

Future<String> obtenerUsuariosTotales() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .get();
  return querySnapshot.docs.length.toString();
}
