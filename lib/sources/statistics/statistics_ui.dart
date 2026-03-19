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
        final user = FirebaseAuth.instance.currentUser;
        final uid = user?.uid ?? '';
        
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
          estadisticas = estadisticasadmin();
        } else {
          estadisticas = estadisticasusuario(uid);
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

  // ==========================================
  // VISTA DE USUARIO / ORGANIZADOR (DATOS FILTRADOS)
  // ==========================================
  Widget estadisticasusuario(String uid) {
    return Column(
      children: [
        Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GraficoEventosHorizontalUsuario(uid: uid),
        ),
        const SizedBox(height: 10),
        Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: GraficoTiposEventosUsuarioSync(uid: uid),
        ),
        const SizedBox(height: 10),
        TopEventosUsuarioGrafico(uid: uid),
      ],
    );
  }

  // ==========================================
  // VISTA DE ADMINISTRADOR (DATOS GLOBALES)
  // ==========================================
  Widget estadisticasadmin() {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            FutureBuilder<String>(
              future: obtenerEventosTotales(),
              builder: (context, snapshot) {
                String valorMostrar = snapshot.hasData ? snapshot.data! : "...";
                return _buildCard("Eventos totales", valorMostrar, Icons.event, PrimaryPurple);
              },
            ),
            FutureBuilder<String>(
              future: obtenerEventosActivos(),
              builder: (context, snapshot) {
                String valorMostrar = snapshot.hasData ? snapshot.data! : "...";
                return _buildCard("Eventos activos", valorMostrar, Icons.local_activity_rounded, Colors.blue);
              },
            ),
            FutureBuilder<String>(
              future: obtenerEventosPrivados(),
              builder: (context, snapshot) {
                String valorMostrar = snapshot.hasData ? snapshot.data! : "...";
                return _buildCard("Eventos privados", valorMostrar, Icons.privacy_tip, Colors.orange);
              },
            ),
            FutureBuilder<String>(
              future: obtenerUsuariosTotales(),
              builder: (context, snapshot) {
                String valorMostrar = snapshot.hasData ? snapshot.data! : "...";
                return _buildCard("Usuarios totales", valorMostrar, Icons.people, Colors.purple);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const GraficoEventosHorizontal(),
        ),
        const SizedBox(height: 10),
        Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: const GraficoTiposEventosSync(),
        ),
        const SizedBox(height: 10),
        const RankingUsuariosGrafico(),
        const SizedBox(height: 10),
        const TopEventosGrafico(),
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
}

// ==========================================
// GRÁFICOS DEL USUARIO (FILTRADOS POR id_organizer)
// ==========================================

class GraficoEventosHorizontalUsuario extends StatelessWidget {
  final String uid;
  const GraficoEventosHorizontalUsuario({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').where('id_organizer', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        Map<int, int> eventosPorMes = {for (var i = 1; i <= 12; i++) i: 0};
        const nombresMeses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final String? dateString = data['startDate'];
          if (dateString != null) {
            try {
              DateTime fecha = DateTime.parse(dateString);
              eventosPorMes[fecha.month] = (eventosPorMes[fecha.month] ?? 0) + 1;
            } catch (e) {
              debugPrint("Error date: $e");
            }
          }
        }

        final List<_ChartData> chartData = eventosPorMes.entries.map((e) {
          return _ChartData(nombresMeses[e.key - 1], e.value);
        }).toList();

        return SfCartesianChart(
          title: ChartTitle(
            text: 'Tus eventos por mes',
            textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            alignment: ChartAlignment.near,
          ),
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(labelFormat: '{value}'),
          series: <CartesianSeries<_ChartData, String>>[
            BarSeries<_ChartData, String>(
              dataSource: chartData,
              xValueMapper: (data, _) => data.mes,
              yValueMapper: (data, _) => data.cantidad,
              color: const Color.fromARGB(255, 131, 64, 255),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        );
      },
    );
  }
}

class GraficoTiposEventosUsuarioSync extends StatelessWidget {
  final String uid;
  const GraficoTiposEventosUsuarioSync({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').where('id_organizer', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

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
            text: 'Tus Eventos por Categoría',
            textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            alignment: ChartAlignment.near,
          ),
          legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
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
      case 'Fiestas': return Colors.red;
      case 'Stand Up': return Colors.orange;
      case 'Teatro': return Colors.yellow;
      case 'Conferencias': return Colors.green;
      case 'Concierto': return Colors.blue;
      case 'Cine': return Colors.indigo;
      default: return Colors.purple;
    }
  }
}

class TopEventosUsuarioGrafico extends StatelessWidget {
  final String uid;
  const TopEventosUsuarioGrafico({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').where('id_organizer', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Center(child: Text("Aún no tienes eventos"));

        // Procesar y ordenar localmente
        List<Map<String, dynamic>> eventosProcesados = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'nombre': data['nombre'] ?? data['title'] ?? 'Evento sin nombre',
            'cantidad': (data['cantidad'] ?? data['asistentes'] ?? 0),
          };
        }).toList();

        eventosProcesados.sort((a, b) => (b['cantidad'] as num).compareTo(a['cantidad'] as num));
        final top5 = eventosProcesados.take(5).toList();

        final double maxCantidad = top5.isEmpty ? 0 : (top5.first['cantidad'] as num).toDouble();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tus eventos más atendidos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 15),
              ...top5.map((item) {
                final double cantidad = (item['cantidad'] as num).toDouble();
                final double porcentaje = maxCantidad > 0 ? (cantidad / maxCantidad) : 0;

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
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${cantidad.toInt()} asistentes',
                            style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
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

// ==========================================
// GRÁFICOS GLOBALES (ADMIN)
// ==========================================

class GraficoEventosHorizontal extends StatelessWidget {
  const GraficoEventosHorizontal({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        Map<int, int> eventosPorMes = {for (var i = 1; i <= 12; i++) i: 0};
        const nombresMeses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final String? dateString = data['startDate'];
          if (dateString != null) {
            try {
              DateTime fecha = DateTime.parse(dateString);
              eventosPorMes[fecha.month] = (eventosPorMes[fecha.month] ?? 0) + 1;
            } catch (e) {
              debugPrint("Error date: $e");
            }
          }
        }

        final List<_ChartData> chartData = eventosPorMes.entries.map((e) {
          return _ChartData(nombresMeses[e.key - 1], e.value);
        }).toList();

        return SfCartesianChart(
          title: ChartTitle(
            text: 'Eventos por mes',
            textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        );
      },
    );
  }
}

class GraficoTiposEventosSync extends StatelessWidget {
  const GraficoTiposEventosSync({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

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
            textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            alignment: ChartAlignment.near,
          ),
          legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
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
      case 'Fiestas': return Colors.red;
      case 'Stand Up': return Colors.orange;
      case 'Teatro': return Colors.yellow;
      case 'Conferencias': return Colors.green;
      case 'Concierto': return Colors.blue;
      case 'Cine': return Colors.indigo;
      default: return Colors.purple;
    }
  }
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
        final double maxEventos = (top5.first['totalEventos'] as num).toDouble();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                ' Top 5 Organizadores',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 12),
              ...top5.map((usuario) {
                final double eventos = (usuario['totalEventos'] as num).toDouble();
                final double porcentaje = maxEventos > 0 ? (eventos / maxEventos) : 0;

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
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${eventos.toInt()} eventos',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 15),
              ...data.map((item) {
                final double cantidad = (item['cantidad'] as num).toDouble();
                final double porcentaje = maxCantidad > 0 ? (cantidad / maxCantidad) : 0;

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
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${cantidad.toInt()} asistentes',
                            style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
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

class _ChartData {
  _ChartData(this.mes, this.cantidad);
  final String mes;
  final int cantidad;
}

class ChartData {
  ChartData(this.tipo, this.cantidad, this.color);
  final String tipo;
  final double cantidad;
  final Color color;
}