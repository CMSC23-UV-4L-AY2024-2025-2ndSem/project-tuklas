import 'package:cloud_firestore/cloud_firestore.dart';

class Itinerary {
  String? planId;
  DateTime? date;
  GeoPoint? location;
  String? notes;

  Itinerary({this.date, this.location, this.notes});

  Map<String, dynamic> toMap() {
    return {
      'date': date?.toString(),
      'location': location,
      'notes': notes,
    };
  }
}