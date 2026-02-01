import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class Mapa extends StatefulWidget {
  const Mapa({super.key});
  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  final MapController controladormapa = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BOCHINCHE')),
      body: Stack(
        children: [
          FlutterMap(
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
                style: LocationMarkerStyle(
                  marker: const DefaultLocationMarker(
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
            ],
          ),
        ],
      ),
    );
  }
}
