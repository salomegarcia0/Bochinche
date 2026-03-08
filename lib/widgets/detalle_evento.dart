import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bochinche_app/features/payment/payment_page.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/sources/reports/reports_ui.dart';
import 'package:bochinche_app/sources/reports/reports_logic.dart';
import 'package:bochinche_app/sources/user_profile/user_profile_ui.dart';
import 'package:bochinche_app/sources/events/comments_section.dart';
import 'package:bochinche_app/widgets/verification_badge.dart';

void mostrarDetalles(
  BuildContext context,
  Map<String, dynamic> data,
  String eventoId,
) {
  // ========================================================
  // 1. CÁLCULO DE TIEMPO MAESTRO (Controla el texto y el botón)
  // ========================================================
  String estadoActual = data['state'] ?? 'Desconocido';
  bool isFinalizado = false;

  try {
    if (data['endDate'] != null && data['endTime'] != null) {
      DateTime endDate = DateTime.parse(data['endDate']);
      int endHour = data['endTime']['hour'];
      int endMinute = data['endTime']['minute'];
      
      DateTime fechaFinReal = DateTime(
        endDate.year, 
        endDate.month, 
        endDate.day, 
        endHour, 
        endMinute
      );

      // Si el momento actual ya pasó la fecha de fin del evento...
      if (DateTime.now().isAfter(fechaFinReal)) {
        isFinalizado = true;
        estadoActual = 'Finalizado';
        
        // Actualizamos Firebase silenciosamente para arreglarlo en la base de datos
        FirebaseFirestore.instance
            .collection('events')
            .doc(eventoId)
            .update({'state': 'Finalizado'})
            .catchError((e) => print("Error silencioso: $e"));
      }
    }
  } catch (e) {
    print("Error calculando fechas: $e");
  }

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
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          eventToReport = eventoId;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const ReportEvents(),
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
                                Icon(Icons.flag_outlined, color: Colors.red, size: 20),
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
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(data['id_organizer'])
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return Text("Organizador: Desconocido");
                            }

                            final userData = snapshot.data!.data() as Map<String, dynamic>;
                            final String nombreOrg = userData['nombre'] ?? 'Sin nombre';

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
                                'Organizador: $nombreOrg',
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      ),
                      if (data['id_organizer'] != null) ...[
                        const SizedBox(width: 4),
                        VerificationBadge(uid: data['id_organizer'], size: 20),
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
                  
                  // ========================================================
                  // 2. TEXTO DEL ESTADO CON COLOR ROJO SI ESTÁ FINALIZADO
                  // ========================================================
                  Text(
                    'Estado: $estadoActual',
                    style: TextStyle(
                      fontWeight: isFinalizado ? FontWeight.bold : FontWeight.normal,
                      color: isFinalizado ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),

                    Row(
                      children: [
                        Builder(
                          builder: (context) {
                            final int sold = data['ticketsSold'] ?? 0;
                            final int cap = data['capacity'] is int
                                ? data['capacity'] as int
                                : int.tryParse(data['capacity']?.toString() ?? '0') ?? 0;
                            
                            final bool isAgotado = sold >= cap;
                            final bool isPayed = data['isPayed'] ?? false;
                            final String? uid = FirebaseAuth.instance.currentUser?.uid;

                            // --------------------------------------------------------
                            // ESCENARIO 1: EL USUARIO NO HA INICIADO SESIÓN
                            // --------------------------------------------------------
                            if (uid == null) {
                              final bool botonDeshabilitado = isAgotado || isFinalizado;
                              String textoBoton = isPayed ? 'Comprar entradas' : 'Reservar Entrada';
                              
                              if (isFinalizado) {
                                textoBoton = 'Evento Finalizado';
                              } else if (isAgotado) {
                                textoBoton = 'Agotado';
                              }

                              return ElevatedButton(
                                onPressed: botonDeshabilitado
                                    ? null 
                                    : () {
                                        // Lo mandamos a iniciar sesión
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const LoginScreen(),
                                          ),
                                        );
                                      },
                                child: Text(textoBoton),
                              );
                            }
                            
                            // --------------------------------------------------------
                            // ESCENARIO 2: EL USUARIO ESTÁ LOGUEADO (VERIFICAMOS SU TICKET)
                            // --------------------------------------------------------
                            return StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .collection('tickets')
                                  .doc(eventoId) 
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final bool yaReservo = snapshot.hasData && snapshot.data!.exists;


                            // ========================================================
                                // 3. LÓGICA DEL BOTÓN A PRUEBA DE BALAS
                                // ========================================================
                                final bool botonDeshabilitado = isAgotado || isFinalizado || yaReservo;

                                String textoBoton = isPayed ? 'Comprar entradas' : 'Reservar Entrada';
                                if (isFinalizado) {
                                  textoBoton = 'Evento Finalizado';
                                } else if (yaReservo) {
                                  textoBoton = 'Ya reservaste';
                                } else if (isAgotado) {
                                  textoBoton = 'Agotado';
                                }

                                return ElevatedButton(
                                  onPressed: botonDeshabilitado
                                      ? null 
                                      : () {
                                          if (isPayed){
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PaymentPage(
                                                  eventData: data,
                                                  eventId: eventoId,
                                                ),
                                              ),
                                            );
                                          } else {
                                            // --------------------------------------------------
                                            // LÓGICA PARA EVENTOS GRATIS
                                            // --------------------------------------------------
                                            registrarUsuarioEnEvento(context, data, eventoId);
                                          }  
                                        },
                                  child: Text(textoBoton),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 2),
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