import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/itinerary_model.dart';

class FirebaseItineraryApi {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // method to fetch itineraries from db
  Stream<QuerySnapshot> getAllItineraries() {
    return db.collection('itineraries').snapshots();
  }

  Future<List<Itinerary>> fetchItineraries(String travelPlanId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('itineraries')
        .where('travelPlanId', isEqualTo: travelPlanId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Itinerary(
        date: data['date'] != null ? DateTime.parse(data['date']) : null,
        location: data['location'],
        notes: data['notes'],
      );
    }).toList();
  }

  Future<String> addItinerary(String travelPlanId, DateTime date) async {
    Map<String, dynamic> itinerary = {
      'planId': '', 
      'date': '',
      'location': null,
      'notes': ''
    };
    try {
      itinerary['planId'] = travelPlanId;
      itinerary['date'] = date;
      itinerary['id'] = db.collection('itineraries').doc().id;
      await db.collection('itineraries').doc(itinerary['id']).set(itinerary);

      return 'Successfully added itinerary!';
    } on FirebaseException catch (e) {
      return 'Error on ${e.code}: ${e.message}';
    }
  }

  Future<String> editItinerary(String id, String travelPlanId, DateTime? date, GeoPoint? location, String? notes) async {
    try {
      await db.collection('itineraries').doc(id).update({
        'date': date,
        'location': location,
        'notes': notes
      });
      return "Successfully added itinerary!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }

  Future<void> createItineraries(dateRange, travelPlanId) async {
    for(int i = 0; i < dateRange.length; i++){
      await addItinerary(travelPlanId, dateRange[i]);
    }
  }
}