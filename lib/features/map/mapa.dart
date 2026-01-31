import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class Mapa extends StatefulWidget {
  final bool esSelector;
  final String tipoEvento;

  const Mapa({super.key, this.esSelector = false, this.tipoEvento = 'Otros'});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  LatLng? puntoSeleccionado;

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

  Color getColorPin(String tipo) {
    switch (tipo) {
      case 'Concierto':
        return Colors.purple;
      case 'Teatro':
        return Colors.orange;
      case 'Cine':
        return Colors.indigo;
      case 'Restaurante':
        return Colors.green;
      case 'Fiestas':
        return Colors.pink;
      case 'Stand Up':
        return Colors.deepOrange;
      case 'Conferencias':
        return Colors.teal;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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
                ),
              ],
            ),
        ],
      ),
    );
  }
}
