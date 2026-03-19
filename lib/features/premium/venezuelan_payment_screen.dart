import 'package:flutter/material.dart';
import 'premium_service.dart';
// JAVIER: Importamos la lógica oficial del proyecto para usar bankList
import 'package:bochinche_app/sources/events/events_logic.dart';

class VenezuelanPaymentScreen extends StatefulWidget {
  final String planName;
  final String price;
  const VenezuelanPaymentScreen({
    super.key,
    required this.planName,
    required this.price,
  });

  @override
  State<VenezuelanPaymentScreen> createState() =>
      _VenezuelanPaymentScreenState();
}

class _VenezuelanPaymentScreenState extends State<VenezuelanPaymentScreen> {
  bool isProcessing = false;
  final formKey = GlobalKey<FormState>();
  late String selectedBank;

  @override
  void initState() {
    super.initState();
    // Javier: Usamos el primer banco de la lista oficial de Adrián
    selectedBank = bankList.first;
  }

  void _confirmarPago() async {
    if (formKey.currentState!.validate()) {
      setState(() => isProcessing = true);

      // Simulación de verificación con el banco
      await Future.delayed(const Duration(seconds: 3));

      bool success = await PremiumService().upgradeUserToPremium(
        widget.planName,
      );

      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => AlertDialog(
            title: const Text("¡Pago Verificado!"),
            content: Text(
              "Tu suscripción al ${widget.planName} se ha activado correctamente.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(c);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("ACEPTAR"),
              ),
            ],
          ),
        );
      }
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reportar Pago Móvil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total: \$${widget.price}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Datos Bochinche: Banesco | 0412-1234567 | J-12345678-9",
                style: TextStyle(fontSize: 12),
              ),
              const Divider(height: 30),

              // DROPDOWN USANDO LA BANKLIST OFICIAL
              const Text(
                "Banco emisor:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: selectedBank,
                isExpanded: true,
                items: bankList
                    .map(
                      (bank) => DropdownMenuItem(
                        value: bank,
                        child: Text(bank, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedBank = val!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Cédula / RIF",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Referencia (Últimos 6 dígitos)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.length < 6 ? "Referencia inválida" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: isProcessing ? null : _confirmarPago,
                  child: isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "REPORTAR PAGO",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
