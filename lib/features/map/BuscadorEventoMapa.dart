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
  }

  @override
  Widget build(BuildContext context) {
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
        ),
      ),
    );
  }
}
