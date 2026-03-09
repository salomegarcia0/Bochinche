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

  // --- MEJORA VISUAL DEL PIN ---
  Widget _buildMarker(String? type) {
    final cat = getCategoryData(type);
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sombra y halo exterior
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (cat['color'] as Color).withValues(alpha: 0.15),
          ),
        ),
        // Pin principal con borde
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cat['color'],
            border: Border.all(
              color: Colors.white,
              width: 3,
            ), // Borde blanco grueso
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(cat['icon'], color: Colors.white, size: 22),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.esSelector
          ? AppBar(
              title: const Text("Toca para ubicar evento"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            )
          : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snap) {
          List<Marker> markers = [];
          if (snap.hasData) {
            markers = snap.data!.docs
                .map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  if (d['location'] == null || d['isPrivate'] == true)
                    return null;
                  return Marker(
                    point: LatLng(
                      d['location'].latitude,
                      d['location'].longitude,
                    ),
                    width: 60,
                    height: 60,
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
                width: 60,
                height: 60,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 55,
                ),
              ),
            );
          }
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(10.4806, -66.8983),
              initialZoom: 14,
              onTap: (tapPos, point) {
                if (widget.esSelector)
                  setState(() => puntoSeleccionado = point);
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
      ),
      floatingActionButton: (widget.esSelector && puntoSeleccionado != null)
          ? FloatingActionButton.extended(
              backgroundColor: Colors.purple,
              onPressed: () => Navigator.pop(context, puntoSeleccionado),
              label: const Text(
                "Confirmar Ubicación",
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
            )
          : null,
    );
  }
}
