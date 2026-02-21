import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bochinche_app/sources/events/comments_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/features/payment/payment_page.dart';

class Mapa extends StatefulWidget implements PreferredSizeWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => MapaState();

  @override
  Size get preferredSize => const Size.fromHeight(300);
}

class MapaState extends State<Mapa> {
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
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Filtramos eventos privados: no se muestran en el mapa público
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
                onTap: () => _mostrarDetalles(context, data, doc.id),
                child: Icon(
                  getIconoPin(data['type']),
                  color: Colors.red,
                  size: 30,
                ),
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

  /// Abre un evento privado por su ID (código de invitación).
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
    if (eventId == null || eventId.isEmpty) return;

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
      // Centrar mapa en el evento
      controladormapa.move(LatLng(punto.latitude, punto.longitude), 16);
      // Mostrar detalles
      if (mounted) _mostrarDetalles(context, data, doc.id);
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

  void _mostrarDetalles(
    BuildContext context,
    Map<String, dynamic> data,
    String eventoId,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Text(
                      'Nombre del evento: ${data['name']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text('Dirección: ${data['address']}'),
                    const SizedBox(height: 6),
                    Text('Contacto o Pagina Web: ${data['contact']}'),
                    const SizedBox(height: 8),
                    Text('Descripción: ${data['description']}'),
                    const SizedBox(height: 8),
                    Text('Aforo: ${data['capacity']}'),
                    const SizedBox(height: 8),
                    Text(
                      'Fecha de inicio: ${DateTime.parse(data['startDate']).day}/${DateTime.parse(data['startDate']).month}/${DateTime.parse(data['startDate']).year}',
                    ),
                    Text(
                      'Fecha de finalización: ${DateTime.parse(data['endDate']).day}/${DateTime.parse(data['endDate']).month}/${DateTime.parse(data['endDate']).year}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hora de inicio: ${data['startTime']['hour'].toString().padLeft(2, '0')}:${data['startTime']['minute'].toString().padLeft(2, '0')}',
                    ),
                    Text(
                      'Hora de finalización: ${data['endTime']['hour'].toString().padLeft(2, '0')}:${data['endTime']['minute'].toString().padLeft(2, '0')}',
                    ),
                    const SizedBox(height: 8),
                    Text('Estado: ${data['state']}'),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final int sold = data['ticketsSold'] ?? 0;
                        final int cap = data['capacity'] is int
                            ? data['capacity'] as int
                            : int.tryParse(data['capacity']?.toString() ?? '0') ?? 0;
                        final bool isAgotado = sold >= cap;

                        return ElevatedButton(
                          onPressed: isAgotado
                              ? null
                              : () {
                                  if (FirebaseAuth.instance.currentUser == null) {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                    );
                                    return;
                                  }
                                  // Abrir flujo de pago unificado con datos del evento
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentPage(
                                        eventData: data,
                                        eventId: eventoId,
                                      ),
                                    ),
                                  );
                                },
                          child: Text(isAgotado ? 'Agotado' : 'Comprar entradas'),
                        );
                      },
                    ),
                    const Divider(),
                    CommentsSection(eventoId: eventoId),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
