<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BuscadorEventoMapa extends StatefulWidget {
  final bool esSelector;
  final String tipoEvento;
  final Function(String)? onSubmitted;

  const BuscadorEventoMapa({
    super.key,
    this.esSelector = false,
    this.tipoEvento = 'Otros',
    this.onSubmitted,
  });

  @override
  State<BuscadorEventoMapa> createState() => _BuscadorEventoMapaState();
}

class _BuscadorEventoMapaState extends State<BuscadorEventoMapa> {
  LatLng? puntoSeleccionado;
  final TextEditingController _searchController = TextEditingController();

  Widget _buildCircularSelector() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // CORRECCIÓN: Usamos withValues para evitar el warning de deprecated
        color: Colors.red.withValues(alpha: 0.2),
      ),
      child: Center(
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 25),
        ),
      ),
    );
=======
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
>>>>>>> origin/develop
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    if (widget.esSelector) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Toca para ubicar evento'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Container(
          color: const Color(0xFFE5E3DF),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(10.4806, -66.8983),
              initialZoom: 15,
              onTap: (tapPos, point) =>
                  setState(() => puntoSeleccionado = point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'bochinche_app',
              ),
              if (puntoSeleccionado != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: puntoSeleccionado!,
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: _buildCircularSelector(),
                    ),
                  ],
                ),
            ],
          ),
        ),
        floatingActionButton: puntoSeleccionado != null
            ? FloatingActionButton.extended(
                onPressed: () => Navigator.pop(context, puntoSeleccionado),
                backgroundColor: Colors.purple,
                label: const Text(
                  'Confirmar Punto',
                  style: TextStyle(color: Colors.white),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
              )
            : null,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Ingresa código de invitación...',
            prefixIcon: const Icon(Icons.search, color: Colors.purple),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.purple),
              onPressed: () {
                if (widget.onSubmitted != null) {
                  widget.onSubmitted!(_searchController.text.trim());
                }
              },
            ),
          ),
          onSubmitted: (value) {
            if (widget.onSubmitted != null) {
              widget.onSubmitted!(value.trim());
            }
          },
=======
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
            children: [Container(), filtro(context)],
          ),
          buscador(context),
        ],
      ),
    );
  }

  Widget filtro(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
      child: FilledButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PublicEventsScreen()),
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
              suffixIcon: _showPasteButton
                  ? IconButton(
                      icon: const Icon(Icons.content_paste, color: PrimaryPurple),
                      onPressed: _pasteFromClipboard,
                      tooltip: 'Pegar código',
                    )
                  : null,
              hintText: 'Buscar evento o código privado',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 16.0,
              ),
            ),
          ),
>>>>>>> origin/develop
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
>>>>>>> origin/develop
