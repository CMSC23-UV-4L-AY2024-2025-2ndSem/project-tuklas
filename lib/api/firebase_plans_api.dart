import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_TUKLAS/api/firebase_auth_api.dart';
import 'package:async/async.dart';

class FirebasePlansApi {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuthAPI authService = FirebaseAuthAPI();

  // method to fetch plans from db
  Stream<QuerySnapshot> getAllTravelPlans() {
    return db.collection('plans').snapshots();
  }

  // method to fetch travel plans created by the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> get createdTravelplan {
    final userId = authService.getCurrentUserId();
    // fetch the plans for the current user and ensure the stream type is correct
    return FirebaseFirestore.instance
        .collection('plans')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot;
        });
  }

  // method to fetch travel plan shared with the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> get sharedTravelPlan {
    final userId = authService.getCurrentUserId();
    // fetch the plans shared with the current user
    return FirebaseFirestore.instance
        .collection('plans')
        .where('sharedWith', arrayContains: userId)
        .snapshots()
        .map((snapshots) {
          return snapshots;
        });
  }

  // method to combine created and shared travel plans
  Stream<QuerySnapshot<Map<String, dynamic>>> get combinedTravelPlans {
    return StreamGroup.merge([createdTravelplan, sharedTravelPlan]);
  }

  // method to add travel plan in db
  Future<String> addPlan(Map<String, dynamic> plan) async {
    try {
      plan['userId'] =
          FirebaseAuth
              .instance
              .currentUser
              ?.uid; // set userId in this plan as the userId of the current user
      plan['id'] = db.collection('plans').doc().id; //generate id
      await db
          .collection('plans')
          .doc(plan['id'])
          .set(plan); // create new document in plan collection
      return "Plan added successfully!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }

  //method to edit existing travel plan in db
  Future<String> editPlan(
    String id,
    String name,
    List<Timestamp> dates,
    GeoPoint location,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('plans').doc(id).update({
        'name': name,
        'dates': dates,
        'location': location,
      });
      return 'Plan updated successfully';
    } catch (e) {
      return 'Error updating plan: $e';
    }
  }

  //method to delete existing travel plan in db
  Future<String> deletePlan(String id, String userId) async {
    try {
      // Check if the user is the owner of the plan
      final planSnapshot = await db.collection('plans').doc(id).get();
      if (!planSnapshot.exists) {
        return "Plan not found.";
      }
      final planData = planSnapshot.data();
      if (planData?['userId'] != userId) {
        return "You do not have permission to delete this plan.";
      }
      // Proceed to delete the plan
      await db.collection('plans').doc(id).delete();
      return "successfully deleted item from plans!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }

  //method to share plan to other user
  Future<String> sharePlan(String? travelPlanId, String? userId) async {
    if (travelPlanId == null || userId == null) {
      return "Travel Plan ID or User ID cannot be null.";
    }
    try {
      await db.collection('plans').doc(travelPlanId).update({
        'sharedWith': FieldValue.arrayUnion([userId]),
      });
      return "Plan added successfully!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    } catch (e) {
      return "Unknown error occurred: $e";
    }
  }

  //method to share travel plan to another user via username
  Future<String> sharePlanToUserViaUsername(
    String travelPlanId,
    String username,
  ) async {
    try {
      // Fetch the user ID based on the username
      final userSnapshot =
          await db
              .collection('users')
              .where('username', isEqualTo: username)
              .get();

      if (userSnapshot.docs.isEmpty) {
        return "User not found.";
      }

      final userId = userSnapshot.docs.first.id;

      // Share the plan with the user ID
      await db.collection('plans').doc(travelPlanId).update({
        'sharedWith': FieldValue.arrayUnion([userId]),
      });

      return "Plan shared successfully!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    } catch (e) {
      return "Unknown error occurred: $e";
    }
  }
}
