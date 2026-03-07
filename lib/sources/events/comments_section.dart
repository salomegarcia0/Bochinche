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
  final TextEditingController _con = TextEditingController();
  int _stars = 5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reseñas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: obtenerComentariosStream(widget.eventoId),
          builder: (context, snap) {
            if (!snap.hasData) return const LinearProgressIndicator();
            final list = snap.data!;
            return Column(
              children: list
                  .map(
                    (c) => ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(c['nombre'] ?? 'Anónimo'),
                      subtitle: Text(
                        "${c['texto']}\n${'⭐' * (c['rating'] ?? 0)}",
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        TextField(
          controller: _con,
          decoration: const InputDecoration(
            hintText: "Escribe un comentario...",
          ),
        ),
        Row(
          children: [
            DropdownButton<int>(
              value: _stars,
              items: [1, 2, 3, 4, 5]
                  .map((v) => DropdownMenuItem(value: v, child: Text("$v ⭐")))
                  .toList(),
              onChanged: (v) => setState(() => _stars = v!),
            ),
            const Spacer(),
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || _con.text.isEmpty) return;
                await agregarComentario(
                  eventoId: widget.eventoId,
                  texto: _con.text,
                  usuarioNombre: user.displayName ?? "Usuario",
                  usuarioUid: user.uid,
                  rating: _stars,
                );
                _con.clear();
              },
              child: const Text("Publicar"),
            ),
          ],
        ),
      ],
    );
  }
}
