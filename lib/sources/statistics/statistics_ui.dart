import 'package:bochinche_app/sources/events/events_logic.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/widgets/NavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:bochinche_app/sources/statistics/statistics_logic.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: Navbar(),
      appBar: BochincheAppBar(),
      body: SafeArea(child: StatisticsUi()),
    );
  }
}

class StatisticsUi extends StatefulWidget {
  const StatisticsUi({super.key});

  @override
  State<StatisticsUi> createState() => _StatisticsUiState();
}

class _StatisticsUiState extends State<StatisticsUi> {
  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'guest';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['rol'] ?? 'usuario';
    } catch (e) {
      return 'usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        final role = snapshot.data ?? 'usuario';
        Text aux = const Text(
          'Panel de Control de Administrador',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        );
        Widget estadisticas = Container();
        if (role == 'admin') {
          estadisticas = estadisticasadmin(role);
        } else {
          estadisticas = estadisticasusuario(role);
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Analiticas de Datos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: PrimaryPurple,
                ),
              ),
              const SizedBox(height: 5),
              const Divider(height: 30),
              if (role == 'admin') aux,
              const SizedBox(height: 20),
              estadisticas,
            ],
          ),
        );
      },
    );
  }

  Widget estadisticasusuario(String id) {
    return Column(
      children: [
        EventosPorMesGrafico(), // Este lo mantenemos como pediste
        const SizedBox(height: 20),
        const MisEventosMasVendidosGrafico(), // Nuevo: Eventos más vendidos
        const SizedBox(height: 20),
        const MisEventosMejorRatingGrafico(), // Nuevo: Eventos con mejor rating
        const SizedBox(height: 20),
      ],
    );
  }

  Widget estadisticasadmin(String id) {
    return Column(
      children: [
        Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GraficoEventosHorizontal(),
        ),
        const SizedBox(height: 10),
        Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: const GraficoTiposEventosSync(),
        ),
        const SizedBox(height: 10),
        RankingUsuariosGrafico(),
        const SizedBox(height: 10),
        TopEventosGrafico(),
      ],
    );
  }

  Widget _buildCard(String title, String val, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<_ChartData> prepararDatosMensuales(List<dynamic> eventos) {
    Map<int, int> conteoMensual = {for (var i = 1; i <= 12; i++) i: 0};
    const nombresMeses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    for (var evento in eventos) {
      final data = evento as Map<String, dynamic>;
      final String? dateString = data['startDate'];

      if (dateString != null) {
        try {
          DateTime fecha = DateTime.parse(dateString);
          conteoMensual[fecha.month] = (conteoMensual[fecha.month] ?? 0) + 1;
        } catch (e) {
          debugPrint("Error con fecha: $dateString");
        }
      }
    }
    return conteoMensual.entries.map((e) {
      return _ChartData(nombresMeses[e.key - 1], e.value);
    }).toList();
  }

  Widget EventosPorMesGrafico() {
    return FutureBuilder<List<dynamic>>(
      future: chargeEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar eventos"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No hay eventos disponibles"));
        }

        final datosProcesados = prepararDatosMensuales(snapshot.data!);

        return Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GraficoEventosHorizontalusuario(datos: datosProcesados),
        );
      },
    );
  }
}

// --- GRÁFICO 1: MIS EVENTOS MÁS VENDIDOS / ASISTIDOS ---
class MisEventosMasVendidosGrafico extends StatelessWidget {
  const MisEventosMasVendidosGrafico({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: chargeEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar eventos"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No tienes eventos registrados"));
        }

        // Procesar los datos de la lista
        List<_ChartData> chartData = [];
        for (var evento in snapshot.data!) {
          final data = evento as Map<String, dynamic>;
          final String nombre = data['name'] ?? 'Sin nombre';
          final int cantidad = data['ticketsSold'] ?? data['ventas'] ?? 0;

          chartData.add(_ChartData(nombre, cantidad));
        }

        // Ordenar de mayor a menor y tomar los 5 mejores
        chartData.sort((a, b) => b.cantidad.compareTo(a.cantidad));
        final top5 = chartData.take(5).toList();

        return Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Mis Eventos Más Vendidos',
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              alignment: ChartAlignment.near,
            ),
            primaryXAxis: CategoryAxis(),
            series: <CartesianSeries<_ChartData, String>>[
              BarSeries<_ChartData, String>(
                dataSource: top5,
                xValueMapper: (_ChartData data, _) => data.mes,
                yValueMapper: (_ChartData data, _) => data.cantidad,
                color: const Color.fromARGB(255, 131, 64, 255),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(5),
                ),
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- CLASE AUXILIAR PARA EL RATING ---
class _RatingData {
  _RatingData(this.nombre, this.rating);
  final String nombre;
  final double rating;
}

// --- GRÁFICO 2: MIS EVENTOS CON MEJOR RATING ---
class MisEventosMejorRatingGrafico extends StatelessWidget {
  const MisEventosMejorRatingGrafico({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: chargeEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar eventos"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No hay datos de rating"));
        }

        List<_RatingData> ratingData = [];
        for (var evento in snapshot.data!) {
          final data = evento as Map<String, dynamic>;

          final String nombre = data['name'] ?? 'Sin nombre';
          final double rating = (data['stars'] ?? 0).toDouble();

          ratingData.add(_RatingData(nombre, rating));
        }

        ratingData.sort((a, b) => b.rating.compareTo(a.rating));
        final top5 = ratingData.take(5).toList();

        return Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Eventos con Mejor Puntuación',
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              alignment: ChartAlignment.near,
            ),
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(minimum: 0, maximum: 5, interval: 1),
            series: <CartesianSeries<_RatingData, String>>[
              ColumnSeries<_RatingData, String>(
                dataSource: top5,
                xValueMapper: (_RatingData data, _) => data.nombre,
                yValueMapper: (_RatingData data, _) => data.rating,
                color: Colors.amber, // Dorado para simular estrellas
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GraficoEventosHorizontalusuario extends StatelessWidget {
  final List<_ChartData> datos;
  const GraficoEventosHorizontalusuario({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      series: <CartesianSeries<_ChartData, String>>[
        BarSeries<_ChartData, String>(
          dataSource: datos,
          xValueMapper: (data, _) => data.mes,
          yValueMapper: (data, _) => data.cantidad,
          color: const Color.fromARGB(255, 131, 64, 255),
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(5),
          ),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
}

class GraficoEventosHorizontal extends StatelessWidget {
  const GraficoEventosHorizontal({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        // 1. Procesamiento de datos (igual que antes)
        Map<int, int> eventosPorMes = {for (var i = 1; i <= 12; i++) i: 0};
        const nombresMeses = [
          'Ene',
          'Feb',
          'Mar',
          'Abr',
          'May',
          'Jun',
          'Jul',
          'Ago',
          'Sep',
          'Oct',
          'Nov',
          'Dic',
        ];

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final String? dateString = data['startDate'];
          if (dateString != null) {
            try {
              DateTime fecha = DateTime.parse(dateString);
              eventosPorMes[fecha.month] =
                  (eventosPorMes[fecha.month] ?? 0) + 1;
            } catch (e) {
              print(e);
            }
          }
        }

        final List<_ChartData> chartData = eventosPorMes.entries.map((e) {
          return _ChartData(nombresMeses[e.key - 1], e.value);
        }).toList();

        return SfCartesianChart(
          title: ChartTitle(
            text: 'Eventos por mes',
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            alignment: ChartAlignment.near,
          ),
          isTransposed: false,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(labelFormat: '{value}'),
          series: <CartesianSeries<_ChartData, String>>[
            BarSeries<_ChartData, String>(
              dataSource: chartData,
              xValueMapper: (_ChartData data, _) => data.mes,
              yValueMapper: (_ChartData data, _) => data.cantidad,
              color: const Color.fromARGB(255, 131, 64, 255),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(5),
              ),
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        );
      },
    );
  }
}

class _ChartData {
  _ChartData(this.mes, this.cantidad);
  final String mes;
  final int cantidad;
}

class GraficoTiposEventosSync extends StatelessWidget {
  const GraficoTiposEventosSync({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        Map<String, int> conteoPorTipo = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final String tipo = data['type'] ?? 'Sin tipo';
          conteoPorTipo[tipo] = (conteoPorTipo[tipo] ?? 0) + 1;
        }

        final List<ChartData> chartData = conteoPorTipo.entries.map((e) {
          return ChartData(e.key, e.value.toDouble(), _obtenerColor(e.key));
        }).toList();

        return SfCircularChart(
          title: ChartTitle(
            text: 'Eventos por Categoría',
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            alignment: ChartAlignment.near,
          ),
          legend: Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
          ),
          series: <CircularSeries>[
            DoughnutSeries<ChartData, String>(
              radius: '100%',
              innerRadius: '0%',
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.tipo,
              yValueMapper: (ChartData data, _) => data.cantidad,
              pointColorMapper: (ChartData data, _) => data.color,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        );
      },
    );
  }

  Color _obtenerColor(String tipo) {
    switch (tipo) {
      case 'Fiestas':
        return Colors.red;
      case 'Stand Up':
        return Colors.orange;
      case 'Teatro':
        return Colors.yellow;
      case 'Conferencias':
        return Colors.green;
      case 'Concierto':
        return Colors.blue;
      case 'Cine':
        return Colors.indigo;
      default:
        return Colors.purple;
    }
  }
}

class ChartData {
  ChartData(this.tipo, this.cantidad, this.color);
  final String tipo;
  final double cantidad;
  final Color color;
}

class RankingUsuariosGrafico extends StatelessWidget {
  const RankingUsuariosGrafico({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: obtenerRankingConNombresReales(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No hay datos"));
        }

        final List<Map<String, dynamic>> top5 = snapshot.data!.take(5).toList();

        final double maxEventos = (top5.first['totalEventos'] as num)
            .toDouble();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                ' Top 5 Organizadores',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 12),

              ...top5.map((usuario) {
                final double eventos = (usuario['totalEventos'] as num)
                    .toDouble();

                final double porcentaje = maxEventos > 0
                    ? (eventos / maxEventos)
                    : 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              usuario['nombre'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${eventos.toInt()} eventos',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            width: constraints.maxWidth * porcentaje,
                            height: 14,
                            decoration: BoxDecoration(
                              color: PrimaryPurple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class TopEventosGrafico extends StatelessWidget {
  const TopEventosGrafico({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: obtenerTop5Eventos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {}

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No hay datos disponibles"));
        }

        final data = snapshot.data!;

        final double maxCantidad = data
            .map((e) => (e['cantidad'] as num).toDouble())
            .reduce((a, b) => a > b ? a : b);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Eventos más atendidos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 15),

              ...data.map((item) {
                final double cantidad = (item['cantidad'] as num).toDouble();
                final double porcentaje = maxCantidad > 0
                    ? (cantidad / maxCantidad)
                    : 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['nombre'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${cantidad.toInt()} asistentes',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            width: constraints.maxWidth * porcentaje,
                            height: 14,
                            decoration: BoxDecoration(
                              color: PrimaryBackGroundPurple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
