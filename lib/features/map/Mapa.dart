import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mapa extends StatefulWidget implements PreferredSizeWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();

  @override
  Size get preferredSize => const Size.fromHeight(300);
}

class _MapaState extends State<Mapa> {
  final MapController controladormapa = MapController();
  IconData getIconoPin(String tipo) {
    switch (tipo) {
      case 'Concierto':
        return Icons.music_note;
      case 'Teatro':
        return Icons.theater_comedy;
      case 'Cine':
        return Icons.movie;
      case 'Restaurante':
        return Icons.restaurant;
      case 'Fiestas':
        return Icons.celebration;
      case 'Stand Up':
        return Icons.sentiment_very_satisfied;
      case 'Conferencias':
        return Icons.mic;
      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Escuchamos la colección "lugares"
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error al cargar datos'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Mapeamos los documentos a una lista de Marcadores
          List<Marker> markers = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final GeoPoint punto = data['location'];

            return Marker(
              point: LatLng(punto.latitude, punto.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _mostrarDetalles(context, data),
                child: getIconoPin(data['type']) != null
                    ? Icon(
                        getIconoPin(data['type']),
                        color: Colors.red,
                        size: 30,
                      )
                    : Icon(Icons.location_on, color: Colors.red, size: 30),
              ),
            );
          }).toList();

          return FlutterMap(
            mapController: controladormapa,
            options: const MapOptions(
              initialCenter: LatLng(0, 0),
              initialZoom: 16,
              minZoom: 0,
              maxZoom: 100,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              CurrentLocationLayer(
                alignPositionOnUpdate: AlignOnUpdate.once,
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  markerSize: Size(30, 30),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }

  void _mostrarDetalles(BuildContext context, var data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles del Evento'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre del evento: ${data['name']}'),
                Text('Dirección: ${data['address']}'),
                Text('Contacto: ${data['contact']}'),
                Text('Descripción: ${data['description']}'),
                Text('Aforo: ${data['capacity']}'),
                Text(
                  'Fecha de inicio: ${DateTime.parse(data['startDate']).day}/${DateTime.parse(data['startDate']).month}/${DateTime.parse(data['startDate']).year}',
                ),
                Text(
                  'Fecha de finalización: ${DateTime.parse(data['endDate']).day}/${DateTime.parse(data['endDate']).month}/${DateTime.parse(data['endDate']).year}',
                ),
                Text(
                  'Hora de inicio: ${data['startTime']['hour'].toString().padLeft(2, '0')}:${data['startTime']['minute'].toString().padLeft(2, '0')}',
                ),
                Text(
                  'Hora de finalización: ${data['endTime']['hour'].toString().padLeft(2, '0')}:${data['endTime']['minute'].toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
