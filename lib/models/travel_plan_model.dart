import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class TravelPlan {
  //required infos
  String? id;
  String name = "";
  List<Timestamp> dates = [];
  GeoPoint? location;
  final String? userId;

  //add more non-required fields here (e.g. flight details, accomodation, notes, checklist, routes, activities)

  TravelPlan({
    this.id,
    required this.name,
    required this.dates,
    required this.location,
    this.userId,
  });

  // Factory constructor to instantiate object from json format
  // to create an Expenses object from a JSON map
  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      id: json['id'],
      name: json['name'],
      dates:
          (json['dates'] as List)
              .map(
                (d) =>
                    d is Timestamp ? d : Timestamp.fromDate(DateTime.parse(d)),
              )
              .toList(),
      location: json['location'],
      userId: json['userId'],
    );
  }

  // to convert a JSON array string into a list of objects
  static List<TravelPlan> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<TravelPlan>((dynamic d) => TravelPlan.fromJson(d)).toList();
  }

  // serializes object into JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dates': dates,
      'location': location,
      'userId': userId,
    };
  }
}
