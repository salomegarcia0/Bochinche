import 'package:flutter/material.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/sources/reports/reports_logic.dart';
import 'package:bochinche_app/styles/NavBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class ReportUser extends StatelessWidget {
  const ReportUser({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: Navbar(),
      appBar: BochincheAppBar(),
      body: ReportUserView(),
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
            subtitle: Text(
              'El evento se muestra en un lugar diferente al real.',
            ),
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
          SizedBox(height: 5),
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
                  setState(() {
                    setReportEventsFalse();
                  });
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

class ReportUserView extends StatefulWidget {
  const ReportUserView({super.key});

  @override
  State<ReportUserView> createState() => _ReportUserViewState();
}

class _ReportUserViewState extends State<ReportUserView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Reportar Usuario',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Describa el problema que encontró con el usuario seleccionado.',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Divider(),
          CheckboxListTile(
            title: Text('Odio'),
            subtitle: Text(
              'Palabras ofensivas, estereotipos racistas o sexistas, deshumanización, incitación al miedo o la discriminación.',
            ),
            value: isHate,
            onChanged: (value) {
              setState(() {
                isHate = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Abuso y acoso'),
            subtitle: Text(
              'Insultos, contenido no deseado de carácter sexual y cosificación explícita, contenido no apto para el ambiente laboral.',
            ),
            value: isHarassment,
            onChanged: (value) {
              setState(() {
                isHarassment = value;
              });
            },

            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Discurso violento'),
            subtitle: Text(
              'Amenazas, intimidación, incitación a la violencia, etc.',
            ),
            value: isViolentDiscourse,
            onChanged: (value) {
              setState(() {
                isViolentDiscourse = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Spam'),
            subtitle: Text('Mensajes no deseados, publicidad excesiva, etc.'),
            value: isSpam,
            onChanged: (value) {
              setState(() {
                isSpam = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Comportamientos ilegales o sujetos a reglamentación'),
            subtitle: Text(
              'Explotación humana, servicios sexuales, drogas, armas, especies en peligro de extinción, facilitación de actividades ilegales.',
            ),
            value: isInappropriateContent,
            onChanged: (value) {
              setState(() {
                isInappropriateContent = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          SizedBox(height: 5),
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
                  reportUser(context);
                  setState(() {
                    setReportUserFalse();
                  });
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
                            j['evento'] == true
                                ? FutureBuilder<String>(
                                    future: getEventName(j['reportId']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text("Cargando...");
                                      }
                                      if (snapshot.hasError) {
                                        return Text("Error");
                                      }
                                      return Text(
                                        'Evento: ${snapshot.data ?? "Evento sin nombre"}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      );
                                    },
                                  )
                                : FutureBuilder<String>(
                                    future: getUserName(j['reportId']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text("Cargando...");
                                      }
                                      if (snapshot.hasError) {
                                        return Text("Error");
                                      }
                                      return Text(
                                        'Usuario: ${snapshot.data ?? "Usuario sin nombre"}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      );
                                    },
                                  ),
                            SizedBox(height: 8),
                            Text(
                              'Razones:  ${j['reason'].toString().replaceFirst('[', '').replaceFirst(']', '')}',
                            ),
                            SizedBox(height: 8),
                            Text('Estado: ${j['status'] ?? 'Desconocido'}'),
                            SizedBox(height: 8),
                            Text('Feedback: ${j['feedback'] ?? 'Desconocido'}'),
                            SizedBox(height: 8),
                            Text(
                              'Fecha del reporte: ${j['timestamp'] != null ? (j['timestamp'] as Timestamp).toDate().toString() : 'Fecha no disponible'}',
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

class AdminReports extends StatelessWidget {
  const AdminReports({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: Navbar(),
      appBar: BochincheAppBar(),
      body: AdminReportsView(),
    );
  }
}

class AdminReportsView extends StatefulWidget {
  const AdminReportsView({super.key});

  @override
  State<AdminReportsView> createState() => _AdminReportsViewState();
}

class _AdminReportsViewState extends State<AdminReportsView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Administrar reportes a usuarios y eventos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Divider(),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: chargeReportsAdmin(),
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
                            j['evento'] == true
                                ? FutureBuilder<String>(
                                    future: getEventName(j['reportId']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text("Cargando...");
                                      }
                                      if (snapshot.hasError) {
                                        return Text("Error");
                                      }
                                      return Text(
                                        'Evento: ${snapshot.data ?? "Evento sin nombre"}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      );
                                    },
                                  )
                                : FutureBuilder<String>(
                                    future: getUserName(j['reportId']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text("Cargando...");
                                      }
                                      if (snapshot.hasError) {
                                        return Text("Error");
                                      }
                                      return Text(
                                        'Usuario: ${snapshot.data ?? "Usuario sin nombre"}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      );
                                    },
                                  ),
                            SizedBox(height: 8),
                            Text(
                              'Razones:  ${j['reason'].toString().replaceFirst('[', '').replaceFirst(']', '')}',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Fecha del reporte: ${j['timestamp'] != null ? (j['timestamp'] as Timestamp).toDate().toString() : 'Fecha no disponible'}',
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Resolver reporte'),
                                      content: TextField(
                                        controller: feedbackController,
                                        maxLines: 4,
                                        decoration: const InputDecoration(
                                          hintText:
                                              'Escribe aquí tu feedback para el usuario...',
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  reportId = j['reportId'];

                                                  if (j['evento'] == true) {
                                                    updateReportStatus(
                                                      j['reportId'],
                                                    );
                                                  } else {
                                                    updateReportStatusUser(
                                                      j['reportId'],
                                                    );
                                                  }
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'Eliminar evento/usuario',
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                ignoreReport(j['reportId']);
                                              },
                                              child: Text('Ignorar reporte'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text('Resolver reporte'),
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
