import 'package:bochinche_app/features/payment/payment_page.dart';
import 'package:bochinche_app/sources/user_profile/user_profile_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bochinche_app/sources/events/comments_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/sources/reports/reports_logic.dart';
import 'package:bochinche_app/sources/reports/reports_ui.dart';
import 'package:bochinche_app/widgets/verification_badge.dart';

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
                onTap: () => mostrarDetalles(context, data, doc.id),
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

  /// Busca un evento por su ID (código de invitación) y lo muestra en el mapa.
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
      // Centrar mapa en el evento
      controladormapa.move(LatLng(punto.latitude, punto.longitude), 16);
      // Mostrar detalles
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

  /// Abre un evento privado pidiendo el código en un diálogo.
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

  void mostrarDetalles(
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

                    // Fila superior con el Título y los Tres Puntos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Nombre del evento: ${data['name']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'reportar') {
                              if (FirebaseAuth.instance.currentUser == null) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                                return;
                              } else {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Reportar evento'),
                                      content: const Text(
                                        '¿Deseas reportar este evento por incumplimiento de las normas?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            eventToReport = eventoId;
                                            print(eventToReport);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ReportEvents(),
                                              ),
                                            );
                                          },
                                          child: const Text('Reportar'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'reportar',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.flag_outlined,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Reportar evento'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: FutureBuilder<DocumentSnapshot>(
                            // Buscamos el documento del organizador usando su ID
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(data['id_organizer'])
                                .get(),
                            builder: (context, snapshot) {
                              // Si hay error o no existe, ponemos un valor por defecto
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return Text("Organizador: Desconocido");
                              }

                              // Extraemos el nombre del documento del usuario
                              final userData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final String nombreOrg =
                                  userData['nombre'] ?? 'Sin nombre';

                              return TextButton(
                                onPressed: () {
                                  userToReport = data['id_organizer'];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrgProfile(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Organizador: $nombreOrg', // <--- ¡Aquí ya tienes el nombre!
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                  overflow: TextOverflow
                                      .ellipsis, // Por si el nombre es muy largo
                                ),
                              );
                            },
                          ),
                        ),
                        if (data['id_organizer'] != null) ...[
                          const SizedBox(width: 4),
                          VerificationBadge(
                            uid: data['id_organizer'],
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4.5),
                    Text('Dirección: ${data['address']}'),
                    const SizedBox(height: 1),
                    Text('Contacto o Pagina Web: ${data['contact']}'),
                    const SizedBox(height: 1),
                    Text('Descripción: ${data['description']}'),
                    const SizedBox(height: 1),
                    Text('Aforo: ${data['capacity']}'),
                    const SizedBox(height: 1),
                    Text(
                      'Fecha de inicio: ${DateTime.parse(data['startDate']).day}/${DateTime.parse(data['startDate']).month}/${DateTime.parse(data['startDate']).year} a las ${data['startTime']['hour'].toString().padLeft(2, '0')}:${data['startTime']['minute'].toString().padLeft(2, '0')}',
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Fecha de finalización: ${DateTime.parse(data['endDate']).day}/${DateTime.parse(data['endDate']).month}/${DateTime.parse(data['endDate']).year} a las ${data['endTime']['hour'].toString().padLeft(2, '0')}:${data['endTime']['minute'].toString().padLeft(2, '0')}',
                    ),
                    const SizedBox(height: 1),
                    Text('Estado: ${data['state']}'),
                    const SizedBox(height: 2),

                    if (data['isPayed']) ...[
                      Row(
                        children: [
                          Builder(
                            builder: (context) {
                              final int sold = data['ticketsSold'] ?? 0;
                              final int cap = data['capacity'] is int
                                  ? data['capacity'] as int
                                  : int.tryParse(
                                          data['capacity']?.toString() ?? '0',
                                        ) ??
                                        0;
                              final bool isAgotado = sold >= cap;

                              return ElevatedButton(
                                onPressed: isAgotado
                                    ? null
                                    : () {
                                        if (FirebaseAuth.instance.currentUser ==
                                            null) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                          return;
                                        }

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
                                child: Text(
                                  isAgotado ? 'Agotado' : 'Comprar entradas',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 2),
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

  Widget _buildCheck({
    required bool? value,
    required String title,
    String? subtitle,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: (bool? newValue) {
        setState(() {
          value = newValue;
        });
      },
      activeColor: Colors.green,
      checkColor: Colors.white,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      controlAffinity: ListTileControlAffinity.leading,
      tristate: true,
    );
  }
}
