import 'package:flutter/material.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/sources/reports/reports_logic.dart';
import 'package:bochinche_app/sources/events/events_ui.dart';

class ReportEvents extends StatelessWidget {
  const ReportEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: const Navbar(),
      appBar: BochincheAppBar(),
      body: ReportEventsForm(),
    );
  }
}

class ReportEventsForm extends StatefulWidget {
  const ReportEventsForm({super.key});

  @override
  State<ReportEventsForm> createState() => _ReportEventsFormState();
}

class _ReportEventsFormState extends State<ReportEventsForm> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Reportar Evento',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Describa el problema que encontró con el evento seleccionado.',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Divider(),
          CheckboxListTile(
            title: Text('Localización Incorrecta'),
            subtitle: Text('.'),
            value: locationError,
            onChanged: (value) {
              setState(() {
                locationError = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Monto Incorrecto'),
            subtitle: Text('Describa el problema en detalle.'),
            value: montoError,
            onChanged: (value) {
              setState(() {
                montoError = value;
              });
            },

            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Incumplimiento de Leyes o Normativas Locales'),
            subtitle: Text('Ruido excesivo, falta de permisos, etc.'),
            value: incumplimientoLey,
            onChanged: (value) {
              setState(() {
                incumplimientoLey = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Fallas de infraestructura'),
            subtitle: Text('Falta de baños, problemas de seguridad, etc.'),
            value: infrastructureFail,
            onChanged: (value) {
              setState(() {
                infrastructureFail = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Otros'),
            subtitle: Text('Describa el problema en detalle.'),
            value: otherError,
            onChanged: (value) {
              setState(() {
                otherError = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),

          if (otherError == true) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextField(
                controller: reportDetailsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Escribe aquí qué sucedió...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  eventToReport = null;
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  reportEvent(context);
                  eventToReport = null;
                  locationError = false;
                  montoError = false;
                  incumplimientoLey = false;
                  infrastructureFail = false;
                  otherError = false;
                  Navigator.pop(context);
                },
                child: Text('Reportar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyReports extends StatelessWidget {
  const MyReports({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: Navbar(),
      appBar: BochincheAppBar(),
      body: MyReportsCards(),
    );
  }
}

class MyReportsCards extends StatefulWidget {
  const MyReportsCards({super.key});

  @override
  State<MyReportsCards> createState() => _MyReportsCardsState();
}

class _MyReportsCardsState extends State<MyReportsCards> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Mis Reportes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Divider(),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: chargeReportsUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error al cargar los reportes');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No has realizado ningún reporte aún.');
              } else {
                List<Map<String, dynamic>> reportes = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: reportes.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> j = reportes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              j['eventId'] ?? 'Evento sin nombre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Razones: ${j['reason'] ?? 'Desconocido'}'),
                            SizedBox(height: 8),
                            Text('Estado: ${j['status'] ?? 'Desconocido'}'),
                            SizedBox(height: 8),
                            Text('Feedback: ${j['feedback'] ?? 'Desconocido'}'),
                            SizedBox(height: 8),
                            Text(
                              'Fecha del reporte: ${j['timestamp'] ?? 'Fecha no disponible'}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
