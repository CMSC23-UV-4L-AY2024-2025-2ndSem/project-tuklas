import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_TUKLAS/api/itinerary_api.dart';

import '../models/itinerary_model.dart';

class ItineraryProvider with ChangeNotifier {
  late Stream<QuerySnapshot> _itineraryStream;
  final FirebaseItineraryApi firebaseService = FirebaseItineraryApi(); //initialize API

  ItineraryProvider() {
    getAllItineraries();
  }

  void getAllItineraries() {
    _itineraryStream = firebaseService.getAllItineraries();
    notifyListeners();
  }

  Future<List<Itinerary>> fetchItineraries(String travelPlanId) async {
    List<Itinerary> itineraries = await firebaseService.fetchItineraries(travelPlanId);
    notifyListeners();
    return itineraries;
  }

  Future<String> addItinerary(String travelPlanId, DateTime date) async {
    String message = await firebaseService.addItinerary(travelPlanId, date);
    notifyListeners();
    return message;
  }
  
  Future<String> editItinerary(String id, String travelPlanId, DateTime? date, GeoPoint? location, String? notes) async {
    String message = await firebaseService.editItinerary(id, travelPlanId, date, location, notes);
    notifyListeners();
    return message;
  }

  Future<void> createItineraries(dateRange, travelPlanId) async {
    await firebaseService.createItineraries(dateRange, travelPlanId);
    notifyListeners();
  }
  
  Future<String> getId(String travelPlanId, DateTime date) async {
    String? id = await firebaseService.getId(travelPlanId, date);
    notifyListeners();
    return id!;
  }

  Future<List<String>> getInfo(String travelPlanId) async {
    List<String> info = await firebaseService.getInfo(travelPlanId);
    print("PROVIDER INFO $info");
    notifyListeners();
    return info;
  }

}