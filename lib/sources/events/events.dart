import 'package:flutter/material.dart';

class Events {
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
}
