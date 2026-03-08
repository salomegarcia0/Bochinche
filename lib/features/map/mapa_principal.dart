import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bochinche_app/widgets/detalle_evento.dart'; 

class MapaPrincipal extends StatefulWidget implements PreferredSizeWidget {
  const MapaPrincipal({super.key});

  @override
  State<MapaPrincipal> createState() => MapaPrincipalState();

  @override
  Size get preferredSize => const Size.fromHeight(300);
}

class MapaPrincipalState extends State<MapaPrincipal> {
  final MapController controladormapa = MapController();

  // ========================================================
  // CICLO DE VIDA: Se ejecuta al abrir el mapa (Entry Point)
  // ========================================================
  @override
  void initState() {
    super.initState();
  }

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
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filtramos eventos privados
          final publicDocs = snapshot.data!.docs.where((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return d['isPrivate'] != true;
          }).toList();

          List<Marker> markers = publicDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final GeoPoint punto = data['location'];

            return Marker(
              point: LatLng(punto.latitude, punto.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => mostrarDetalles(context, data, doc.id),
                child: Icon(
                  getIconoPin(data['type'] ?? 'Otros'),
                  color: Colors.red,
                  size: 30,
                ),
              ),
            );
          }).toList();

          return FlutterMap(
            mapController: controladormapa,
            options: const MapOptions(
              initialCenter: LatLng(10.4806, -66.8983), // Caracas, UNIMET
              initialZoom: 16,
              minZoom: 0,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.bochinche_app',
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

  Future<void> buscarPorCodigo(String eventId) async {
    if (eventId.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();
      if (!doc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento no encontrado. Verifica el código.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint punto = data['location'];
      controladormapa.move(LatLng(punto.latitude, punto.longitude), 16);
      if (mounted) mostrarDetalles(context, data, doc.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> buscarEventoPrivado(BuildContext context) async {
    final codeCtrl = TextEditingController();
    final eventId = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Buscar Evento Privado'),
        content: TextField(
          controller: codeCtrl,
          decoration: const InputDecoration(
            hintText: 'Pega el código de invitación',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.vpn_key),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, codeCtrl.text.trim()),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
    if (eventId != null) {
      await buscarPorCodigo(eventId);
    }
  }
}