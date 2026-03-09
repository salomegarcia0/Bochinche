import 'package:bochinche_app/styles/Color.dart';
import 'package:flutter/material.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/sources/reports/reports_logic.dart';
import 'package:bochinche_app/widgets/NavBar.dart';
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
          Center(
            child: Text(
              'Describa el problema que encontró con el evento seleccionado.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),

          Divider(),
          CheckboxListTile(
            title: Text(
              'Localización Incorrecta',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            title: Text(
              'Monto Incorrecto',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            title: Text(
              'Incumplimiento de Leyes o Normativas Locales',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            title: Text(
              'Fallas de infraestructura',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            title: Text('Otros', style: TextStyle(fontWeight: FontWeight.bold)),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                    129,
                    238,
                    238,
                    238,
                  ), // Un gris claro y limpio
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  eventToReport = null;
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PrimaryPurple, // Tu morado
                  foregroundColor: Colors.white,
                  elevation: 0, // Plano se ve más moderno
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bordes suaves
                  ),
                ),
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
          Center(
            child: Text(
              'Describa el problema que encontró con el usuario seleccionado.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),

          Divider(),
          CheckboxListTile(
            title: Text('Odio', style: TextStyle(fontWeight: FontWeight.bold)),
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
            title: Text(
              'Abuso y acoso',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            title: Text(
              'Discurso violento',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            title: Text('Spam', style: TextStyle(fontWeight: FontWeight.bold)),
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
            title: Text(
              'Comportamientos ilegales o sujetos a reglamentación',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(129, 238, 238, 238),
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  eventToReport = null;
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PrimaryPurple, // Tu morado
                  foregroundColor: Colors.white,
                  elevation: 0, // Plano se ve más moderno
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bordes suaves
                  ),
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
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
                  physics: const NeverScrollableScrollPhysics(),
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
                                      return Row(
                                        children: [
                                          const Icon(
                                            Icons
                                                .celebration, // Icono de fiesta/evento
                                            color:
                                                PrimaryBackGroundPurple, // Tu morado característico
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${snapshot.data ?? "Evento sin nombre"}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis, // Evita que el texto rompa el diseño si es muy largo
                                            ),
                                          ),
                                        ],
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
                                      return Row(
                                        children: [
                                          const Icon(
                                            Icons
                                                .person_3_sharp, // El icono de persona
                                            color:
                                                PrimaryBackGroundPurple, // Tu color morado
                                            size:
                                                24, // Un tamaño que acompañe bien al texto
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ), // Un pequeño espacio entre icono y texto
                                          Expanded(
                                            // Expanded evita errores si el nombre es muy largo
                                            child: Text(
                                              '${snapshot.data ?? "Usuario sin nombre"}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis, // Si el nombre es gigante, pone "..."
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                            SizedBox(height: 8),
                            Wrap(
                              children: [
                                Text(
                                  'Razones: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${j['reason'].toString().replaceFirst('[', '').replaceFirst(']', '')}',
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Estado del reporte: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: j['status'] == 'Pendiente'
                                        ? const Color.fromARGB(
                                            255,
                                            207,
                                            158,
                                            21,
                                          ).withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    j['status'] == 'Pendiente'
                                        ? 'Pendiente'
                                        : 'Resuelto',
                                    style: TextStyle(
                                      color: j['status'] == 'Pendiente'
                                          ? const Color.fromARGB(
                                              255,
                                              207,
                                              158,
                                              21,
                                            )
                                          : Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8),
                            Wrap(
                              children: [
                                Text(
                                  'Feedback: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${j['feedback'] ?? 'Desconocido'}'),
                              ],
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              children: [
                                Text(
                                  'Fecha del reporte: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${j['timestamp'] != null ? (j['timestamp'] as Timestamp).toDate().toString() : 'Fecha no disponible'}',
                                ),
                              ],
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            'Administrar reportes',
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
                  physics: const NeverScrollableScrollPhysics(),
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
                                      return Row(
                                        children: [
                                          const Icon(
                                            Icons
                                                .celebration, // Icono de fiesta/evento
                                            color:
                                                PrimaryBackGroundPurple, // Tu morado característico
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${snapshot.data ?? "Evento sin nombre"}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis, // Evita que el texto rompa el diseño si es muy largo
                                            ),
                                          ),
                                        ],
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
                                      return Row(
                                        children: [
                                          const Icon(
                                            Icons
                                                .person_3_sharp, // El icono de persona
                                            color:
                                                PrimaryBackGroundPurple, // Tu color morado
                                            size:
                                                24, // Un tamaño que acompañe bien al texto
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ), // Un pequeño espacio entre icono y texto
                                          Expanded(
                                            // Expanded evita errores si el nombre es muy largo
                                            child: Text(
                                              '${snapshot.data ?? "Usuario sin nombre"}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis, // Si el nombre es gigante, pone "..."
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                            SizedBox(height: 8),
                            Wrap(
                              children: [
                                Text(
                                  'Razones: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${j['reason'].toString().replaceFirst('[', '').replaceFirst(']', '')}',
                                ),
                              ],
                            ),

                            SizedBox(height: 8),
                            Wrap(
                              children: [
                                Text(
                                  'Fecha del reporte: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${j['timestamp'] != null ? (j['timestamp'] as Timestamp).toDate().toString() : 'Fecha no disponible'}',
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PrimaryBackGroundPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Resolver reporte',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.cancel),
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    Colors.grey[600],
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              label: Text('Cancelar'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            ElevatedButton.icon(
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
                                              icon: const Icon(
                                                Icons.delete_forever,
                                              ),
                                              label: const Text(
                                                'Eliminar evento/usuario',
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.redAccent,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                            ElevatedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: PrimaryPurple,
                                                side: const BorderSide(
                                                  color: PrimaryPurple,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                ignoreReport(j['reportId']);
                                                setState(() {});
                                                Navigator.of(context).pop();
                                              },
                                              icon: const Icon(
                                                Icons.visibility_off,
                                              ),
                                              label: const Text(
                                                'Ignorar reporte',
                                              ),
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
