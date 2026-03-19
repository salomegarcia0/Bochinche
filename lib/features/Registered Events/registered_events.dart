import 'package:flutter/material.dart';

import 'package:bochinche_app/widgets/NavBar.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/features/Registered Events/registered_events_logic.dart';
import 'package:bochinche_app/styles/Color.dart';

class registered_events extends StatefulWidget {
  const registered_events({super.key});

  @override
  State<registered_events> createState() => _registered_events();
}

class _registered_events extends State<registered_events> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco principal
      appBar: const BochincheAppBar(),
      drawer: const Navbar(),
      body: SafeArea(child: cuerpo(context)),
    );
  }

  Widget cuerpo(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Eventos Reservados",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: PrimaryPurple,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFEBE6F3), thickness: 1, height: 20),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: RegisteredEventsLogic().chargeEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: PrimaryPurple),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Hubo un error al cargar tus reservas."),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aún no tienes entradas reservadas.\n¡Anímate a ir a un bochinche!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: PrimaryPurple),
                    ),
                  );
                }

                List<Map<String, dynamic>> eventos = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: eventos.length,
                  itemBuilder: (context, index) {
                    var evento = eventos[index];

                    // ==========================================
                    // EXTRACCIÓN Y FORMATO DE DATOS
                    // ==========================================
                    String nombre = evento['name'] ?? 'Evento sin nombre';
                    bool isFinalizado = evento['isFinalizado'] ?? false;
                    bool isPayed = evento['isPayed'] ?? false;
                    var montoPagado =
                        evento['totalPaid'] ??
                        (evento['paymentInfo'] != null
                            ? evento['paymentInfo']['price']
                            : null) ??
                        evento['price'] ??
                        '0.00';

                    String precioTexto = isPayed ? '$montoPagado Bs' : 'Gratis';

                    // Fecha bonita (DD/MM/YYYY)
                    String fechaFormateada = 'Por definir';
                    try {
                      if (evento['startDate'] != null) {
                        DateTime parsedDate = DateTime.parse(
                          evento['startDate'],
                        );
                        fechaFormateada =
                            '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
                      }
                    } catch (e) {
                      fechaFormateada = 'Formato inválido';
                    }

                    // Hora bonita (HH:MM)
                    String horaFormateada = 'Por definir';
                    try {
                      if (evento['startTime'] != null) {
                        String hora = evento['startTime']['hour']
                            .toString()
                            .padLeft(2, '0');
                        String minuto = evento['startTime']['minute']
                            .toString()
                            .padLeft(2, '0');
                        horaFormateada = '$hora:$minuto';
                      }
                    } catch (e) {
                      horaFormateada = 'Formato inválido';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F4FD),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 20,
                              bottom: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // AQUI ESTÁ LA MAGIA 👇
                                Text(
                                  "${index + 1}. Detalles de la Reserva",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: PrimaryPurple,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isFinalizado
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isFinalizado ? 'Finalizado' : 'Activo',
                                    style: TextStyle(
                                      color: isFinalizado
                                          ? Colors.red[800]
                                          : Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Color(0xFFEBE6F3),
                            thickness: 1,
                            height: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Evento",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        nombre,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Fecha",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      fechaFormateada,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Hora",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      horaFormateada,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Tipo de entrada",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      isPayed
                                          ? 'Pagada ($precioTexto)'
                                          : 'Gratuita',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isPayed
                                            ? Colors.blue[700]
                                            : PrimaryPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
