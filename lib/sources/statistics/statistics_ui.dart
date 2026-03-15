import 'package:bochinche_app/sources/reports/reports_ui.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/widgets/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/widgets/verification_badge.dart';
import 'package:bochinche_app/sources/reports/reports_logic.dart';
import 'package:bochinche_app/styles/Color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bochinche_app/sources/statistics/statistics_logic.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Analíticas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          Text(
            'Describa el problema que encontró con el evento seleccionado.',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),

          Divider(),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              FutureBuilder<String>(
                future: obtenerEventosTotales(),
                builder: (context, snapshot) {
                  String valorMostrar = snapshot.hasData
                      ? snapshot.data!
                      : "...";

                  return _buildCard(
                    "Eventos totales",
                    valorMostrar,
                    Icons.event,
                    Colors.green,
                  );
                },
              ),
              FutureBuilder<String>(
                future: obtenerEventosActivos(),
                builder: (context, snapshot) {
                  String valorMostrar = snapshot.hasData
                      ? snapshot.data!
                      : "...";

                  return _buildCard(
                    "Eventos activos",
                    valorMostrar,
                    Icons.local_activity_rounded,
                    Colors.blue,
                  );
                },
              ),
              FutureBuilder<String>(
                future: obtenerEventosPrivados(),
                builder: (context, snapshot) {
                  String valorMostrar = snapshot.hasData
                      ? snapshot.data!
                      : "...";

                  return _buildCard(
                    "Eventos privados",
                    valorMostrar,
                    Icons.privacy_tip,
                    Colors.orange,
                  );
                },
              ),

              FutureBuilder<String>(
                future: obtenerUsuariosTotales(),
                builder: (context, snapshot) {
                  String valorMostrar = snapshot.hasData
                      ? snapshot.data!
                      : "...";

                  return _buildCard(
                    "Usuarios totales",
                    valorMostrar,
                    Icons.people,
                    Colors.purple,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
          Container(
            height: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GraficoEventosHorizontal(),
          ),
          const SizedBox(height: 50),
          Container(
            height: 300,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GraficoTiposEventosSync(),
          ),
          Container(
            height: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RankingUsuariosGrafico(),
          ),
          Container(
            height: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TopEventosGrafico(),
          ),
        ],
      ),
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
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
          title: ChartTitle(text: 'Eventos por mes'),
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
          title: ChartTitle(text: 'Eventos por Categoría'),
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

        // Invertimos la lista para que el Top 1 aparezca arriba
        final List<Map<String, dynamic>> top5 = snapshot.data!
            .take(5)
            .toList()
            .reversed
            .toList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Ranking de Usuarios',
              alignment: ChartAlignment.near,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.indigo,
              ),
            ),
            isTransposed: false, // Barras horizontales
            plotAreaBorderWidth: 0,
            primaryXAxis: const CategoryAxis(
              isVisible:
                  false, // Ocultamos el eje porque los nombres van arriba
              borderWidth: 0,
            ),
            primaryYAxis: const NumericAxis(
              isVisible: false, // Ocultamos el eje de valores
            ),
            series: <CartesianSeries<Map<String, dynamic>, String>>[
              BarSeries<Map<String, dynamic>, String>(
                dataSource: top5,
                xValueMapper: (Map<String, dynamic> data, _) => data['nombre'],
                yValueMapper: (Map<String, dynamic> data, _) =>
                    data['totalEventos'],

                // Estilo de la barra igual a tu imagen
                color: const Color(0xFFFF7B7B), // Color coral/rosado
                width: 0.3, // Grosor de la barra
                borderRadius: BorderRadius.circular(10),

                // CONFIGURACIÓN DE LAS ETIQUETAS (Texto arriba)
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  // Coloca la etiqueta encima de la barra
                  labelPosition: ChartDataLabelPosition.outside,
                  labelAlignment: ChartDataLabelAlignment.top,
                  textStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo,
                  ),
                ),

                dataLabelMapper: (Map<String, dynamic> data, _) {
                  return '${data['nombre']}                                       ${data['totalEventos']} eventos';
                },
              ),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No hay datos disponibles"));
        }

        final data = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBFF), // Fondo sutilmente lila/blanco
            borderRadius: BorderRadius.circular(20),
          ),
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Eventos más atendidos',
              alignment: ChartAlignment.near,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            isTransposed: true,
            plotAreaBorderWidth: 0,
            primaryXAxis: const CategoryAxis(isVisible: false),
            primaryYAxis: const NumericAxis(isVisible: false),

            annotations: data.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;

              return CartesianChartAnnotation(
                widget: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.only(bottom: 45),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['nombre'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5E548E),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${item['cantidad']} asistentes',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                coordinateUnit: CoordinateUnit.point,
                x: item['nombre'],
                y: 0,
                region: AnnotationRegion.plotArea,
                horizontalAlignment: ChartAlignment.near,
              );
            }).toList(),

            series: <CartesianSeries<Map<String, dynamic>, String>>[
              BarSeries<Map<String, dynamic>, String>(
                dataSource: data,
                xValueMapper: (Map<String, dynamic> ev, _) => ev['nombre'],
                yValueMapper: (Map<String, dynamic> ev, _) => ev['cantidad'],

                color: const Color(0xFFFF8585),
                width: 0.25,
                borderRadius: const BorderRadius.all(Radius.circular(10)),

                animationDuration: 1500,
              ),
            ],
          ),
        );
      },
    );
  }
}
