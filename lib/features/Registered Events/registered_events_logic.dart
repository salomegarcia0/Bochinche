import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisteredEventsLogic {
  Future<List<Map<String, dynamic>>> chargeEvents() async {
    List<Map<String, dynamic>> eventosReservados = [];
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return [];

    try {
      QuerySnapshot ticketsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tickets')
          .get();

      for (var doc in ticketsSnapshot.docs) {
        Map<String, dynamic> ticketData = doc.data() as Map<String, dynamic>;
        String eventId = doc.id;
        DocumentSnapshot eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .get();

        if (eventDoc.exists) {
          Map<String, dynamic> eventData =
              eventDoc.data() as Map<String, dynamic>;
          eventData['id'] = eventDoc.id;

          eventData['ticket_info'] = ticketData;

          eventosReservados.add(eventData);
        }
      }
    } catch (e) {
      print("Error cargando eventos reservados: $e");
    }

    return eventosReservados;
  }
}
