import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:bochinche_app/widgets/bochinche_marker.dart';

class SelectorUbicacion extends StatefulWidget {
  final bool esSelector;
  final String tipoEvento;

  const SelectorUbicacion({
    super.key,
    this.esSelector = false,
    this.tipoEvento = 'Otros',
  });

  @override
  State<SelectorUbicacion> createState() => _SelectorUbicacionState();
}

class _SelectorUbicacionState extends State<SelectorUbicacion> {
  LatLng? puntoSeleccionado;
  String? direccionSeleccionada;
  final MapController mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _buscando = false;

  Future<String> _obtenerDireccion(LatLng point) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1',
    );

    try {
      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': 'BochincheApp/1.0 (contacto@bochinche.app)',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData != null && decodedData['address'] != null) {
          final address = decodedData['address'];
          final street =
              address['road'] ??
              address['pedestrian'] ??
              address['path'] ??
              address['footway'] ??
              address['suburb'] ??
              address['neighbourhood'] ??
              'Calle desconocida';
          final city =
              address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'] ??
              address['county'] ??
              address['state'] ??
              'Ciudad desconocida';
          return '$street, $city';
        } else {
          return 'Dirección no encontrada';
        }
      } else {
        return 'Error al obtener la dirección';
      }
    } catch (e) {
      return 'Error de conexión';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    mapController.dispose();
    super.dispose();
  }

  Future<void> _buscarUbicacion() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _buscando = true);
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newPoint = LatLng(loc.latitude, loc.longitude);

        mapController.move(newPoint, 16.0);

        if (widget.esSelector) {
          if (esPuntoEnCaracas(newPoint)) {
            setState(() {
              puntoSeleccionado = newPoint;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '⚠️ El lugar buscado está fuera de los límites permitidos',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró la ubicación')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ubicación no encontrada')));
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
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
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(10.4806, -66.8983),
              initialZoom: 16,
              onTap: (tapPos, point) async {
                if (widget.esSelector) {
                  if (esPuntoEnCaracas(point)) {
                    setState(() {
                      puntoSeleccionado = point;
                      direccionSeleccionada = 'Cargando dirección...';
                    });

                    final address = await _obtenerDireccion(point);

                    if (mounted) {
                      setState(() {
                        direccionSeleccionada = address;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(direccionSeleccionada!),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "⚠️ Solo puedes seleccionar ubicaciones dentro de Caracas",
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
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
              if (puntoSeleccionado != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: puntoSeleccionado!,
                      width: 50,
                      height: 50,
                      child: BochincheMarker(
                        iconContent: getIconoPin(widget.tipoEvento),
                        size: 50,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar ubicación (Ej: Caracas)',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  suffixIcon: _buscando
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: _buscarUbicacion,
                        ),
                ),
                onSubmitted: (_) => _buscarUbicacion(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool esPuntoEnCaracas(LatLng punto) {
    final List<LatLng> limitesCaracas = [
      const LatLng(10.5190, -66.9600), // Noroeste (Cerca de Catia/Ávila)
      const LatLng(10.5300, -66.8200), // Noreste (Cerca de Palo Verde/Ávila)
      const LatLng(10.4200, -66.7800), // Sureste (Cerca de El Hatillo)
      const LatLng(10.4100, -66.9500), // Suroeste (Cerca de Caricuao)
    ];

    var intersectCount = 0;
    for (var j = 0; j < limitesCaracas.length; j++) {
      var vertJ = limitesCaracas[j];
      var vertI = limitesCaracas[(j + 1) % limitesCaracas.length];

      if ((vertI.latitude > punto.latitude) !=
              (vertJ.latitude > punto.latitude) &&
          (punto.longitude <
              (vertJ.longitude - vertI.longitude) *
                      (punto.latitude - vertI.latitude) /
                      (vertJ.latitude - vertI.latitude) +
                  vertI.longitude)) {
        intersectCount++;
      }
    }
    return intersectCount % 2 != 0;
  }
}
