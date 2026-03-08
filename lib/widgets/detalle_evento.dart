import 'package:flutter/material.dart';
import 'package:bochinche_app/features/payment/payment_page.dart';
import 'package:bochinche_app/sources/events/events_logic.dart' as logic;
import 'package:bochinche_app/sources/user_profile/user_profile_ui.dart';
import 'package:bochinche_app/sources/events/comments_section.dart';

void mostrarDetalles(
  BuildContext context,
  Map<String, dynamic> data,
  String eventoId,
) {
  String estadoActual = data['state'] ?? 'Desconocido';
  bool isFinalizado = estadoActual == 'Finalizado';

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evento: ${data['name']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  logic.userToReport = data['id_organizer'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const OrgProfile()),
                  );
                },
                child: Text("Organizador: ${data['id_organizer']}"),
              ),
              const Divider(),
              Text("Descripción: ${data['description']}"),
              Text(
                "Estado: $estadoActual",
                style: TextStyle(
                  color: isFinalizado ? Colors.red : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isFinalizado
                    ? null
                    : () {
                        if (data['isPayed'] == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => PaymentPage(
                                eventData: data,
                                eventId: eventoId,
                              ),
                            ),
                          );
                        } else {
                          logic.registrarUsuarioEnEvento(
                            context,
                            data,
                            eventoId,
                          );
                        }
                      },
                child: Text(
                  data['isPayed'] == true ? "Comprar Entradas" : "Reservar",
                ),
              ),
              const Divider(),
              CommentsSection(eventoId: eventoId),
            ],
          ),
        ),
      ),
    ),
  );
}
