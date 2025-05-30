import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_TUKLAS/api/firebase_auth_api.dart';
import 'package:project_TUKLAS/api/firebase_plans_api.dart';
import 'package:project_TUKLAS/models/travel_plan_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TravelPlanProvider with ChangeNotifier {
  late Stream<QuerySnapshot> _travelsStream;
  final FirebasePlansApi firebaseService = FirebasePlansApi(); //initialize API
  final FirebaseAuthAPI authService = FirebaseAuthAPI();

  TravelPlanProvider() {
    fetchTravelPlans();
  }

  // method to get all plans from Firestore
  void fetchTravelPlans() {
    _travelsStream = firebaseService.getAllTravelPlans();
    notifyListeners();
  }

  // method to get travel plans created by the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> createdTravelPlans() {
    print("Fetching created travel plans");
    return firebaseService.createdTravelplan;
  }

  // method to get travel plans shared with the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> sharedTravelPlans() {
    print("Fetching shared travel plans");
    return firebaseService.sharedTravelPlan;
  }

  // method to get sahred and created travel plans of the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> allTravelPlans() {
    print("Fetching all travel plans");
    return firebaseService.combinedTravelPlans;
  }

  // method to add plans and store in Firestore
  Future<String> addPlan(TravelPlan plan) async {
    String id = await firebaseService.addPlan(plan.toJson());
    print(id);
    notifyListeners();
    return id;
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
  Future<String> deletePlan(String id, String userId) async {
    String message = await firebaseService.deletePlan(id, userId);
    print(message);
    notifyListeners();
    return message;
  }

  // method to share plan to user
  Future<String?> sharePlan(String? travelPlanId) async {
    final userId = authService.getCurrentUserId();
    String message = await firebaseService.sharePlan(travelPlanId, userId);
    print(message);
    notifyListeners();
    return message;
  }

  // method to share travel plan to another user via username
  Future<String?> sharePlanToUserViaUsername(
    String travelPlanId,
    String username,
  ) async {
    String message = await firebaseService.sharePlanToUserViaUsername(
      travelPlanId,
      username,
    );
    print(message);
    notifyListeners();
    return message;
  }

  // Method to get the current authenticated user
  User? getCurrentUser() {
    return authService.auth.currentUser;
  }

  // Method to fetch user data by UID from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  // method to get users sharing this plan
  Future<List<Map<String, dynamic>>> getSharedWith(String? planId) async {
    List<Map<String, dynamic>> users = await firebaseService.getSharedWith(
      planId!,
    );
    print(users);
    notifyListeners();
    return users;
  }

  //method to remove user in shareWith field from plan collection
  Future<String> removeUser(String userId, String? planId) async {
    String message = await firebaseService.removeUser(userId, planId!);
    print(message);
    notifyListeners();
    return message;
  }
}
