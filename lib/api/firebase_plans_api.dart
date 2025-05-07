import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebasePlansApi {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // method to fetch plans from db
  Stream<QuerySnapshot> getAllTravelPlans() {
    return db.collection('plans').snapshots();
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
  Future<String> deletePlan(String id) async {
    try {
      await db.collection('plans').doc(id).delete();
      return "Successfully deleted item from plans!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }
}
