import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/sources/events/events_logic.dart';

class CommentsSection extends StatefulWidget {
  final String eventoId;
  const CommentsSection({super.key, required this.eventoId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Comentarios",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: obtenerComentariosStream(widget.eventoId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final comments = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(comments[i]['nombre'] ?? "Anónimo"),
                subtitle: Text(comments[i]['texto'] ?? ""),
              ),
            );
          },
        ),
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: "Escribe un comentario...",
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                if (_commentController.text.isNotEmpty) {
                  final user = FirebaseAuth.instance.currentUser;
                  await agregarComentario(
                    eventoId: widget.eventoId,
                    texto: _commentController.text,
                    usuarioNombre: user?.displayName ?? "Usuario",
                    usuarioUid: user?.uid ?? "",
                  );
                  _commentController.clear();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
