import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> obtenerImagenes(String id) async {
  List<String> imagenes = [
    'https://camarasal.com/wp-content/uploads/2020/08/default-image-5-1.jpg',
  ];

  try {
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(id)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      List<dynamic> arregloImagenes = data['gallery'] ?? imagenes;

      return arregloImagenes.map((link) {
        String url = link.toString();

        if (url.contains('via.placeholder.com')) {
          return imagenes.first;
        }

        return url;
      }).toList();
    }
    return imagenes;
  } catch (e) {
    print("Error al cargar la galería: $e");
    return imagenes;
  }
}
