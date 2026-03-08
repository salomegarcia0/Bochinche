import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/widgets/detalle_evento.dart';

class SelectorUbicacion extends StatefulWidget {
  final bool esSelector;
  final String tipoEvento;
  const SelectorUbicacion({
    super.key,
    this.esSelector = false,
    this.tipoEvento = 'Otros',
  });
  @override
  SelectorUbicacionState createState() => SelectorUbicacionState();
}

class SelectorUbicacionState extends State<SelectorUbicacion> {
  final MapController _mapController = MapController();
  LatLng? puntoSeleccionado;

  Future<void> buscarPorCodigo(String cod) async {
    final doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(cod)
        .get();
    if (!mounted || !doc.exists) return;
    final d = doc.data() as Map<String, dynamic>;
    _mapController.move(
      LatLng(d['location'].latitude, d['location'].longitude),
      16,
    );
    mostrarDetalles(context, d, doc.id);
  }

  Widget _buildMarker(String? type) {
    final cat = getCategoryData(type);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (cat['color'] as Color).withValues(alpha: 0.2),
          ),
        ),
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cat['color'],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(cat['icon'], color: Colors.white, size: 20),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snap) {
        List<Marker> markers = [];
        if (snap.hasData) {
          markers = snap.data!.docs
              .map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                if (d['location'] == null || d['isPrivate'] == true) {
                  return null;
                }
                return Marker(
                  point: LatLng(
                    d['location'].latitude,
                    d['location'].longitude,
                  ),
                  width: 55,
                  height: 55,
                  child: GestureDetector(
                    onTap: () => mostrarDetalles(context, d, doc.id),
                    child: _buildMarker(d['type']),
                  ),
                );
              })
              .whereType<Marker>()
              .toList();
        }
        if (widget.esSelector && puntoSeleccionado != null) {
          markers.add(
            Marker(
              point: puntoSeleccionado!,
              width: 50,
              height: 50,
              child: const Icon(Icons.location_on, color: Colors.red, size: 45),
            ),
          );
        }
        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(10.4806, -66.8983),
            initialZoom: 14,
            onTap: (tapPos, point) {
              if (widget.esSelector) setState(() => puntoSeleccionado = point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",
              subdomains: const ['a', 'b', 'c', 'd'],
            ),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }
}
