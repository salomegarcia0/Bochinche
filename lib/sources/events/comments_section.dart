import 'package:bochinche_app/sources/reports/reports_ui.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'events_logic.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/widgets/verification_badge.dart';
import 'package:bochinche_app/sources/reports/reports_logic.dart';

class CommentsSection extends StatefulWidget {
  final String eventoId;
  const CommentsSection({super.key, required this.eventoId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;
  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _currentName =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'Bochinchero';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comentarios', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: obtenerComentariosStream(widget.eventoId),
          builder: (context, snap) {
            if (snap.hasError) return Text('Error al cargar comentarios');
            if (!snap.hasData) return const CircularProgressIndicator();
            final comentarios = snap.data!;
            if (comentarios.isEmpty) return const Text('Sin comentarios aún');
            return SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: comentarios.length,
                itemBuilder: (context, i) {
                  final c = comentarios[i];
                  final ts = c['fecha'];
                  final int rating = (c['rating'] is int)
                      ? c['rating'] as int
                      : (c['rating'] is double
                            ? (c['rating'] as double).toInt()
                            : 0);
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(c['nombre'] ?? 'Usuario'),
                                  if (c['usuarioUid'] != null) ...[
                                    const SizedBox(width: 4),
                                    VerificationBadge(
                                      uid: c['usuarioUid'],
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.grey,
                                ),
                                onSelected: (value) {
                                  if (value == 'reportar') {
                                    if (FirebaseAuth.instance.currentUser ==
                                        null) {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                      return;
                                    } else {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                              'Reportar usuario',
                                            ),
                                            content: const Text(
                                              '¿Deseas reportar este usuario por incumplimiento de las normas?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  userToReport =
                                                      c['usuarioUid'];
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ReportUser(),
                                                    ),
                                                  );
                                                },
                                                child: const Text('Reportar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'reportar',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.flag_outlined,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Reportar usuario'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            final colored = index < rating;
                            return Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: SvgPicture.asset(
                                'assets/svgs/2451996.svg',
                                width: 16,
                                height: 16,
                                color: colored
                                    ? Colors.orange
                                    : Colors.grey.shade400,
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 5),
                        Text(c['texto'] ?? ''),
                        const SizedBox(height: 6),
                      ],
                    ),
                    trailing: ts is Timestamp
                        ? Text(
                            (ts.toDate()).toLocal().toString().split('.').first,
                            style: const TextStyle(fontSize: 10),
                          )
                        : null,
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          decoration: const InputDecoration(labelText: 'Escribe un comentario'),
        ),
        Row(
          children: [
            const Text('Valoración:'),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: _rating,
              items: List.generate(5, (i) => i + 1)
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                  .toList(),
              onChanged: (v) => setState(() => _rating = v ?? 5),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (FirebaseAuth.instance.currentUser == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                  return;
                }
                final texto = _commentController.text.trim();
                if (texto.isEmpty) return;
                try {
                  await agregarComentario(
                    eventoId: widget.eventoId,
                    texto: texto,
                    usuarioNombre: _currentName,
                    usuarioUid: _currentUid,
                    rating: _rating,
                  );
                  await agregarValoracion(
                    eventoId: widget.eventoId,
                    rating: _rating,
                    usuarioUid: _currentUid,
                  );
                  _commentController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comentario y valoración guardados'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ],
    );
  }
}
