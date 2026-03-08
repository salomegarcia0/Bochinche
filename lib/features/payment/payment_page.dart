import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentPage extends StatefulWidget {
  /// Datos del evento desde Firestore. Contiene 'paymentInfo', 'name', etc.
  final Map<String, dynamic>? eventData;

  /// ID del documento del evento en Firestore.
  final String eventId;

  const PaymentPage({super.key, this.eventData, required this.eventId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int quantity = 1;

  // Capacidad y entradas vendidas (leídas del eventData)
  int _capacity = 0;
  int _ticketsSold = 0;
  int get _remaining => (_capacity - _ticketsSold).clamp(0, _capacity);

  final TextEditingController _refCtrl = TextEditingController();
  bool _loading = false;
  bool _validRef = false;
  bool _copySuccess = false;

  // Datos de pago del organizador
  String _bankName = 'No especificado';
  String _phone = 'No especificado';
  String _ci = 'No especificado';
  double _price = 0.0;
  String _eventName = 'Evento';

  @override
  void initState() {
    super.initState();
    _refCtrl.addListener(_validateRef);
    _loadEventPaymentInfo();
  }

  void _loadEventPaymentInfo() {
    final d = widget.eventData;
    if (d == null) return;
    _eventName = d['name'] ?? 'Evento';
    _capacity = d['capacity'] is int
        ? d['capacity'] as int
        : int.tryParse(d['capacity']?.toString() ?? '0') ?? 0;
    _ticketsSold = (d['ticketsSold'] ?? 0) as int;
    // Aseguramos que quantity no supere los lugares disponibles
    quantity = quantity.clamp(1, _remaining > 0 ? _remaining : 1);
    final pi = d['paymentInfo'] as Map<String, dynamic>?;
    if (pi != null) {
      _bankName = (pi['bank'] as String?)?.isNotEmpty == true
          ? pi['bank'] as String
          : 'No especificado';
      _phone = (pi['phone'] as String?)?.isNotEmpty == true
          ? pi['phone'] as String
          : 'No especificado';
      _ci = (pi['ci'] as String?)?.isNotEmpty == true
          ? pi['ci'] as String
          : 'No especificado';
      _price = (pi['price'] ?? 0.0).toDouble();
    }
  }

  void _validateRef() {
    final txt = _refCtrl.text.trim();
    final isValid = txt.length >= 4 && txt.length <= 6;
    if (isValid != _validRef) {
      if (mounted) setState(() => _validRef = isValid);
    }
  }

  @override
  void dispose() {
    _refCtrl.removeListener(_validateRef);
    _refCtrl.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    final paymentInfo = 'Pago Móvil\nBanco: $_bankName\nTlf: $_phone\nCI: $_ci';
    await Clipboard.setData(ClipboardData(text: paymentInfo));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos de pago copiados al portapapeles')),
      );
      setState(() => _copySuccess = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _copySuccess = false);
      });
    }
  }

  Future<void> _confirmPayment() async {
    final ref = _refCtrl.text.trim();
    if (ref.length < 4 || ref.length > 6) {
      _showMessage(
        'El número de referencia debe tener 4-6 dígitos.',
        isError: true,
      );
      return;
    }

    setState(() => _loading = true);
    final ok = await _verifyMockPayment(ref);

    if (!mounted) return;

    if (!ok) {
      setState(() => _loading = false);
      _showMessage('Pago rechazado (código de prueba 0000).', isError: true);
      return;
    }

    // Guardar en Firestore de forma atómica
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuario no autenticado');

      final eventRef = FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId);
      final userTicketsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tickets')
          .doc(widget.eventId);

      await FirebaseFirestore.instance.runTransaction((txn) async {
        final eventSnap = await txn.get(eventRef);
        final currentSold = (eventSnap.data()?['ticketsSold'] ?? 0) as int;
        final rawCap = eventSnap.data()?['capacity'];
        final cap = rawCap is int
            ? rawCap
            : int.tryParse(rawCap?.toString() ?? '0') ?? 0;

        if (currentSold + quantity > cap) {
          throw Exception('No hay suficientes entradas disponibles.');
        }

        // Incrementar entradas vendidas en el evento
        txn.update(eventRef, {'ticketsSold': FieldValue.increment(quantity)});

        // Guardar la compra en el perfil del usuario
        txn.set(userTicketsRef, {
          'eventId': widget.eventId,
          'id_evento': widget.eventId,
          'eventName': _eventName,
          'quantity': quantity,
          'totalPaid': _price * quantity,
          'reference': ref,
          'isPayed': true,
          'purchasedAt': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;
      setState(() => _loading = false);

      final total = _price * quantity;
      await _showMessage(
        'Pago confirmado.\nReferencia: $ref\nEntradas: $quantity\nTotal: ${total.toStringAsFixed(2)} Bs',
      );
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Error al guardar el pago: $e', isError: true);
    }
  }

  Future<bool> _verifyMockPayment(String ref) async {
    await Future.delayed(const Duration(seconds: 2));
    return ref != '0000';
  }

  Future<void> _showMessage(String text, {bool isError = false}) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isError ? 'Error' : '¡Éxito!',
          style: TextStyle(color: isError ? Colors.red : Colors.green),
        ),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _price * quantity;

    return Scaffold(
      appBar: AppBar(title: Text(_eventName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SECCIÓN 1: CANTIDAD
            _buildSectionCard(
              theme,
              title: '1. Cantidad de Entradas',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Entradas', style: TextStyle(fontSize: 16)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                              icon: const Icon(Icons.remove),
                              color: theme.primaryColor,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              // Limitar al máximo de entradas disponibles
                              onPressed:
                                  (_remaining == 0 || quantity >= _remaining)
                                  ? null
                                  : () => setState(() => quantity++),
                              icon: const Icon(Icons.add),
                              color: theme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_price > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Precio por entrada:',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          '${_price.toStringAsFixed(2)} Bs',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${total.toStringAsFixed(2)} Bs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SECCIÓN 2: INSTRUCCIONES DE PAGO
            _buildSectionCard(
              theme,
              title: '2. Realizar Pago Móvil',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Realiza el pago a los siguientes datos del organizador:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Banco: $_bankName',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Teléfono: $_phone',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Text('C.I: $_ci', style: const TextStyle(fontSize: 15)),
                        if (_price > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Monto a transferir: ${total.toStringAsFixed(2)} Bs',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: Icon(
                        _copySuccess ? Icons.check : Icons.copy,
                        size: 18,
                      ),
                      label: Text(
                        _copySuccess ? 'Copiado' : 'Copiar Datos Bancarios',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _copySuccess
                            ? Colors.green
                            : theme.primaryColor,
                        side: BorderSide(
                          color: _copySuccess
                              ? Colors.green
                              : theme.primaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SECCIÓN 3: CONFIRMACIÓN
            _buildSectionCard(
              theme,
              title: '3. Confirmar Pago',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingresa el número de referencia de tu transferencia.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _refCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 6,
                    enabled: !_loading,
                    decoration: const InputDecoration(
                      labelText: 'Número de Referencia',
                      hintText: 'Últimos 4-6 dígitos',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _validRef ? _confirmPayment : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'CONFIRMAR PAGO',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    ThemeData theme, {
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            const Divider(height: 24, thickness: 1),
            child,
          ],
        ),
      ),
    );
  }
}
