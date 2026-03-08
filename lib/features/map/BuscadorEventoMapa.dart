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

  // Verifica si hay texto copiado al abrir el componente
  Future<void> _checkClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      setState(() {
        _showPasteButton = true;
      });
    }
  }

  // Pega el texto del portapapeles y ejecuta la búsqueda
  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _controller.text = data.text!;
        _showPasteButton = false;
      });
      // Al pegar, también ejecutamos la búsqueda automáticamente
      if (widget.onSubmitted != null) {
        widget.onSubmitted!(data.text!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      decoration: BoxDecoration(
        color: PrimaryBackGroundPurple,
        borderRadius: BorderRadius.circular(35.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(), // Espaciador
              _botonFiltro(context),
            ],
          ),
          _buscadorInput(context),
        ],
      ),
    );
  }

  Widget _botonFiltro(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
      child: FilledButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PublicEventsScreen()),
          );
        },
        style: FilledButton.styleFrom(
          backgroundColor: PrimaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        child: const Text('Filtros', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buscadorInput(BuildContext context) {
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
            controller: _controller,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: PrimaryPurple),
              suffixIcon: _showPasteButton
                  ? IconButton(
                      icon: const Icon(
                        Icons.content_paste,
                        color: PrimaryPurple,
                      ),
                      onPressed: _pasteFromClipboard,
                      tooltip: 'Pegar código',
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: PrimaryPurple,
                      ),
                      onPressed: () {
                        if (widget.onSubmitted != null) {
                          widget.onSubmitted!(_controller.text.trim());
                        }
                      },
                    ),
              hintText: 'Buscar evento o código privado',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 16.0,
              ),
            ),
            onSubmitted: (value) {
              if (widget.onSubmitted != null) {
                widget.onSubmitted!(value.trim());
              }
            },
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
