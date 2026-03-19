import 'package:bochinche_app/styles/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bochinche_app/sources/events/events_ui.dart';

class BuscadorEventoMapa extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onSubmitted;

  const BuscadorEventoMapa({super.key, this.onSubmitted});

  @override
  State<BuscadorEventoMapa> createState() => _BuscadorEventoMapaState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BuscadorEventoMapaState extends State<BuscadorEventoMapa> {
  final TextEditingController _controller = TextEditingController();
  bool _showPasteButton = false;

  @override
  void initState() {
    super.initState();
    _checkClipboard();
  }

  // Verifica si hay texto copiado al abrir la pantalla
  Future<void> _checkClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _showPasteButton = true;
      });
    }
  }

  // Pega el texto y oculta el botón automáticamente
  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _controller.text = data!.text!;
        _showPasteButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
        decoration: BoxDecoration(
          color: PrimaryBackGroundPurple,
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: buscador(context),
      ),
    );
  }

  Widget buscador(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SecondaryPurple,
            borderRadius: BorderRadius.circular(50.0),
            border: Border.all(color: PrimaryPurple, width: 1.0),
          ),
          child: TextField(
            readOnly: true,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const PublicEventsScreen(),
                  transitionDuration: const Duration(milliseconds: 800),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                ),
              );
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: PrimaryPurple),
              hintText: 'Buscar evento o código privado',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
