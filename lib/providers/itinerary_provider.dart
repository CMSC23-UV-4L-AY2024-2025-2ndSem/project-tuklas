import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_TUKLAS/api/itinerary_api.dart';

class ItineraryProvider with ChangeNotifier {
  late Stream<QuerySnapshot> _itineraryStream;
  final FirebaseItineraryApi firebaseService = FirebaseItineraryApi(); //initialize API

  ItineraryProvider() {
    fetchAllItineraries();
  }

  // method to get all itineraries from Firestore
  void fetchAllItineraries() {
    _itineraryStream = firebaseService.getAllItineraries();
    notifyListeners();
  }

  Future<void> fetchItineraries(String travelPlanId) async {
    await firebaseService.fetchItineraries(travelPlanId);
    notifyListeners();
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
  
}