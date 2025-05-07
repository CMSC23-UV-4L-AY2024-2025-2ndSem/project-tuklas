import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_TUKLAS/api/firebase_plans_api.dart';
import 'package:project_TUKLAS/models/travel_plan_model.dart';

class TravelPlanProvider with ChangeNotifier {
  late Stream<QuerySnapshot> _travelsStream;
  final FirebasePlansApi firebaseService = FirebasePlansApi(); //initialize API

  TravelPlanProvider() {
    fetchTravelPlans();
  }

  // method to get all plans from Firestore
  void fetchTravelPlans() {
    _travelsStream = firebaseService.getAllTravelPlans();
    notifyListeners();
  }

  // method to get travel plans for the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> get travelplan {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // return an empty stream of the correct type if user is null
      return FirebaseFirestore.instance
          .collection('plans')
          .where('userId', isEqualTo: '__nouser__') // Use an impossible value
          .snapshots()
          // cast the resulting stream's snapshot type
          .map((snapshot) => snapshot as QuerySnapshot<Map<String, dynamic>>);
    }

    // fetch the plans for the current user and ensure the stream type is correct
    return FirebaseFirestore.instance
        .collection('plans')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot as QuerySnapshot<Map<String, dynamic>>;
        });
  }

  // method to add plans and store in Firestore
  Future<void> addPlan(TravelPlan plan) async {
    String message = await firebaseService.addPlan(plan.toJson());
    print(message);
    notifyListeners();
  }

  // method to edit plans and update in Firestore (using the provided editPlan)
    Future<void> editPlan(
      String id,
      String name,
      List<Timestamp> dates, // ✅ make sure it's Timestamp
      GeoPoint location,
    ) async {
      String message = await firebaseService.editPlan(id, name, dates, location);
      print(message);
      notifyListeners();
    }



  // method to delete plans and update in Firestore
  Future<void> deletePlan(String id) async {
    String message = await firebaseService.deletePlan(id);
    print(message);
    notifyListeners();
  }
}
