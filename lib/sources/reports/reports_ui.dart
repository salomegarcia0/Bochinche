import 'package:flutter/material.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:bochinche_app/sources/reports/reports_logic.dart';
import 'package:bochinche_app/styles/NavBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportEvents extends StatefulWidget {
  const ReportEvents({super.key});
  @override
  State<ReportEvents> createState() => _ReportEventsState();
}

class _ReportEventsState extends State<ReportEvents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navbar(),
      appBar: const BochincheAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Reportar Evento',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            CheckboxListTile(
              title: const Text('Localización Incorrecta'),
              value: locationError,
              onChanged: (v) => setState(() => locationError = v!),
            ),
            CheckboxListTile(
              title: const Text('Monto Incorrecto'),
              value: montoError,
              onChanged: (v) => setState(() => montoError = v!),
            ),
            CheckboxListTile(
              title: const Text('Fallas de infraestructura'),
              value: infrastructureFail,
              onChanged: (v) => setState(() => infrastructureFail = v!),
            ),
            CheckboxListTile(
              title: const Text('Otros'),
              value: otherError,
              onChanged: (v) => setState(() => otherError = v!),
            ),
            if (otherError)
              TextField(
                controller: reportDetailsController,
                decoration: const InputDecoration(
                  hintText: 'Detalle el problema...',
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                reportEvent(context);
                setReportEventsFalse();
                Navigator.pop(context);
              },
              child: const Text('Enviar Reporte'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminReports extends StatelessWidget {
  const AdminReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navbar(),
      appBar: const BochincheAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('status', isEqualTo: 'Pendiente')
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(
                    d['evento'] == true
                        ? "Evento Reportado"
                        : "Usuario Reportado",
                  ),
                  subtitle: Text("Motivos: ${d['reason']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.gavel, color: Colors.red),
                    onPressed: () => _showResolveDialog(context, docs[i].id, d),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showResolveDialog(
    BuildContext context,
    String reportId,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Resolver Reporte"),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(hintText: "Feedback..."),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ignoreReport(reportId).then((_) => Navigator.pop(context)),
            child: const Text("Ignorar"),
          ),
          TextButton(
            onPressed: () {
              if (data['evento'] == true) {
                updateReportStatus(reportId, data['eventId']);
              } else {
                updateReportStatusUser(reportId, data['userId']);
              }
              Navigator.pop(context);
            },
            child: const Text(
              "Eliminar y Banear",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
