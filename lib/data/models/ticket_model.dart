class TicketModel {
  final String id;
  final String eventId;
  final String userId;
  final String status; // 'pendiente', 'pagado'
  final String paymentRef; // Referencia del pago móvil
  final DateTime purchaseDate;

  TicketModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.paymentRef,
    required this.purchaseDate,
  });

  // Convierte el Mapa de Firebase en un Objeto Ticket usable
  factory TicketModel.fromMap(Map<String, dynamic> map, String id) {
    return TicketModel(
      id: id,
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      status: map['status'] ?? 'pendiente',
      paymentRef: map['paymentRef'] ?? '',
      purchaseDate: (map['purchaseDate'] as dynamic).toDate(),
    );
  }

  // Convierte el Objeto Ticket a Mapa para subirlo a Firebase
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'status': status,
      'paymentRef': paymentRef,
      'purchaseDate': purchaseDate,
    };
  }
}