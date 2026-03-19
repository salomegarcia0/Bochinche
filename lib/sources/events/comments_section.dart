import 'package:bochinche_app/sources/reports/reports_ui.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'events_logic.dart';
import 'package:bochinche_app/features/auth/LoginScreen.dart';
import 'package:bochinche_app/widgets/verification_badge.dart';
import 'package:bochinche_app/sources/reports/reports_logic.dart';
import 'package:bochinche_app/styles/Color.dart';

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
  
  // Eliminamos _currentName porque ahora buscaremos el username en Firebase

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
  // Volvemos a min para no pelear con el ListView
  mainAxisSize: MainAxisSize.min, 
  children: [
    // Usamos Flexible en lugar de Expanded para evitar el error de "hasSize"
    Flexible(
      child: Text(
        // Verificamos nulos antes de hacer cualquier cosa
        (c['nombre'] != null)
            ? (c['nombre'].toString().startsWith('@') 
                ? c['nombre'] 
                : '@${c['nombre']}')
            : '@usuario',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: PrimaryPurple,
          fontSize: 14,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ),
    // Verificamos que el UID no sea nulo antes de mostrar la medalla
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
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                    129,
                                                    238,
                                                    238,
                                                    238,
                                                  ),
                                                  foregroundColor:
                                                      Colors.black87,
                                                  elevation: 0,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      12,
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancelar'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      PrimaryPurple, // Tu morado
                                                  foregroundColor: Colors.white,
                                                  elevation:
                                                      0, // Plano se ve más moderno
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      12,
                                                    ), // Bordes suaves
                                                  ),
                                                ),
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
                  // ==========================================
                  // NUEVA LÓGICA: GUARDAR CON USERNAME
                  // ==========================================
                  // 1. Buscamos el username del usuario actual en Firestore
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentUid)
                      .get();
                      
                  String nombreParaGuardar = 'Bochinchero';
                  
                  if (userDoc.exists) {
                    final data = userDoc.data() as Map<String, dynamic>;
                    if (data.containsKey('username') && data['username'].toString().isNotEmpty) {
                      nombreParaGuardar = '@${data['username']}'; // Guardamos con el @ incluido
                    } else {
                      nombreParaGuardar = data['nombre'] ?? 'Bochinchero'; // Respaldo viejo
                    }
                  }

                  // 2. Guardamos el comentario
                  await agregarComentario(
                    eventoId: widget.eventoId,
                    texto: texto,
                    usuarioNombre: nombreParaGuardar, // Ahora pasa el @username
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
