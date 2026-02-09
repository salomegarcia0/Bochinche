class Events {
  String? id;
  String? nameEvent;
  String? short_loc;
  String? description;
  String? event_type;
  String? people_quantity;
  String? event_date_init;
  String? event_date_end;
  String? longitude;
  String? latitude;

  Events(
    this.id,
    this.nameEvent,
    this.short_loc,
    this.description,
    this.event_type,
    this.people_quantity,
    this.event_date_init,
    this.event_date_end,
  );

  void setLocation(String lon, String lat) {
    longitude = lon;
    latitude = lat;
  }
}

/* Future<void> createEvent(BuildContext context) async {
  try {
    final documento = FirebaseFirestore.instance.collection("events").doc();
    await documento.set({
      'id': documento.id,
      'name': nombreEventoController.text,
      'direction': direccionController.text,
      'ini_date': fecha1.toString(),
      'fin_date': fecha2.toString(),
      'quantity': aforoController.text,
      'type': typeC,
      'description': descripcionController.text,
    });
    print(documento.id);
  } catch (e) {
    print("Error $e");
  } */

 /* lass Events {
  String? name_event;
  String? event_organizer;
  String? short_loc;
  String? contact_phone;
  String? description;
  String? event_type;
  int? people_quantity;
  DateTime? event_date_init;
  DateTime? event_date_end;
  String? longitude;
  String? latitude;
  TimeOfDay? hour_begin;
  TimeOfDay? hour_end;

  Events(
    this.name_event,
    this.event_organizer,
    this.short_loc,
    this.contact_phone,
    this.description,
    this.event_type,
    this.people_quantity,
    this.event_date_init,
    this.event_date_end,
    this.hour_begin,
    this.hour_end,
  );


  void setLocation(String lon, String lat) {
    this.longitude = lon;
    this.latitude = lat;
  }
} */