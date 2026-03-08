import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/sources/events/comments_section.dart';
import 'package:bochinche_app/features/payment/payment_page.dart';

<<<<<<< HEAD:lib/features/map/mapa.dart
class MapaPrincipal extends StatefulWidget {
  const MapaPrincipal({super.key});
  @override
  State<MapaPrincipal> createState() => MapaPrincipalState();
}

class MapaPrincipalState extends State<MapaPrincipal> {
  final MapController _con = MapController();
=======
class SelectorUbicacion extends StatefulWidget {
  final bool esSelector;
  final String tipoEvento;

  const SelectorUbicacion({super.key, this.esSelector = false, this.tipoEvento = 'Otros'});

  @override
  State<SelectorUbicacion> createState() => _SelectorUbicacionState();
}

class _SelectorUbicacionState extends State<SelectorUbicacion> {
  LatLng? puntoSeleccionado;
>>>>>>> origin/develop:lib/features/map/selector_ubicacion.dart

  Widget _buildMarker(String? type) {
    final cat = getCategoryData(type);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (cat['color'] as Color).withValues(alpha: 0.2),
          ),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cat['color'],
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(cat['icon'], color: Colors.white, size: 18),
        ),
      ],
    );
  }

  void _mostrarDetalles(
    BuildContext context,
    Map<String, dynamic> d,
    String id,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scroll,
            children: [
              Row(
                children: [
                  Icon(
                    getCategoryData(d['type'])['icon'],
                    color: getCategoryData(d['type'])['color'],
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      d['name'] ?? 'Evento',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),
              Text(d['description'] ?? 'Sin descripción'),
              const SizedBox(height: 25),
              // FIX: En listas (ListView children), el 'if' no lleva llaves {}
              if (d['isPayed'] == true)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => PaymentPage(eventData: d, eventId: id),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text("COMPRAR ENTRADAS"),
                ),
              const SizedBox(height: 25),
              CommentsSection(eventoId: id),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD:lib/features/map/mapa.dart
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());

        final markers = snap.data!.docs
            .map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              if (d['location'] == null || d['isPrivate'] == true) return null;

              return Marker(
                point: LatLng(d['location'].latitude, d['location'].longitude),
                width: 55,
                height: 55,
                child: GestureDetector(
                  onTap: () => _mostrarDetalles(context, d, doc.id),
                  child: _buildMarker(d['type']),
=======
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.esSelector ? 'Ubicación para ${widget.tipoEvento}' : 'Mapa',
        ),
        actions: [
          if (widget.esSelector && puntoSeleccionado != null)
            IconButton(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context, puntoSeleccionado),
            ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(10.4806, -66.8983),
          initialZoom: 15,
          onTap: (tapPos, point) {
            if (widget.esSelector) {
              setState(() => puntoSeleccionado = point);
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.bochinche_app',
          ),
          CurrentLocationLayer(),
          if (puntoSeleccionado != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: puntoSeleccionado!,
                  width: 50,
                  height: 50,
                  child: Icon(
                    getIconoPin(widget.tipoEvento),
                    color: getColorPin(widget.tipoEvento),
                    size: 45,
                  ),
>>>>>>> origin/develop:lib/features/map/selector_ubicacion.dart
                ),
              );
            })
            .whereType<Marker>()
            .toList();

        return FlutterMap(
          mapController: _con,
          options: const MapOptions(
            initialCenter: LatLng(10.4806, -66.8983),
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'bochinche_app',
            ),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }

  Future<void> buscarPorCodigo(String cod) async {
    final doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(cod)
        .get();
    // FIX: Verificación de mounted para evitar errores al mover el mapa si el usuario salió de la pantalla
    if (!mounted) return;
    if (doc.exists) {
      final d = doc.data() as Map<String, dynamic>;
      _con.move(LatLng(d['location'].latitude, d['location'].longitude), 16);
      _mostrarDetalles(context, d, doc.id);
    }
  }
}
