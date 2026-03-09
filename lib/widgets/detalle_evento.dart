import 'package:flutter/material.dart';
import 'package:bochinche_app/features/payment/payment_page.dart';
import 'package:bochinche_app/sources/reports/reports_ui.dart';
import 'package:bochinche_app/sources/reports/reports_logic.dart';
import 'package:bochinche_app/sources/events/events_logic.dart' as logic;
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
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data['name'] ?? 'Evento',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flag_rounded, color: Colors.red),
                    onPressed: () {
                      eventToReport = eventoId;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const ReportEvents()),
                      );
                    },
                  ),
                ],
              ),
              const Divider(),
              Text("Descripción: ${data['description'] ?? 'Sin descripción'}"),
              const SizedBox(height: 10),
              Text(
                "Estado: $estadoActual",
                style: TextStyle(
                  color: isFinalizado ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                icon: const Icon(Icons.shopping_cart),
                label: Text(
                  data['isPayed'] == true
                      ? "COMPRAR ENTRADAS"
                      : "RESERVAR ENTRADA",
                ),
              ),
              const SizedBox(height: 30),
              CommentsSection(eventoId: eventoId),
            ],
          ),
        ),
      ),
    ),
  );
}
