import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/itinerary_model.dart';

class FirebaseItineraryApi {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAllItineraries() {
    return db.collection('itineraries').snapshots();
  }

  Future<List<Itinerary>> fetchItineraries(String travelPlanId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('plans')
        .doc(travelPlanId)
        .collection('itineraries')
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
      await db.collection('plans').doc(travelPlanId).collection('itineraries').doc(itinerary['id']).set(itinerary);

      return 'Successfully added itinerary!';
    } on FirebaseException catch (e) {
      return 'Error on ${e.code}: ${e.message}';
    }
  }

  Future<String> editItinerary(String id, String travelPlanId, DateTime? date, GeoPoint? location, String? notes) async {
    try {
      await db.collection('plans').doc(travelPlanId).collection('itineraries').doc(id).update({
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

  Future<String?> getId(String travelPlanId, DateTime date) async {
    String? id;
    QuerySnapshot querySnapshot = await FirebaseFirestore
      .instance // snapshot of db with usernames similar to user input username
      .collection('plans')
      .doc(travelPlanId)
      .collection('itineraries')
      .where('date', isEqualTo: date)
      .limit(1)
      .get();

        if (querySnapshot.docs.isEmpty) {
          id = null;
          return id;
        } else {
          id = querySnapshot.docs[0]['id'];
          return id;
        }
  }

  Future<List<String>> getInfo(String travelPlanId) async {
    List<String> info = [];
    String? notes;
    GeoPoint? location;
    await FirebaseFirestore
      .instance // snapshot of db with usernames similar to user input username
      .collection('plans')
      .doc(travelPlanId)
      .collection('itineraries')
      .orderBy('date')
      .get()
      .then((QuerySnapshot querySnapshot) {
        print(querySnapshot.docs.length);
        for (int i = 0; i < querySnapshot.docs.length; i++){
          if (querySnapshot.docs.isEmpty) {
            location = null;
            notes = null;
          } else {
            notes = querySnapshot.docs[i]['notes'];
            location = querySnapshot.docs[i]['location'];
            if (notes == null) {
              info.add('No notes yet!');
            } else {
              info.add(notes as String);
            }
            if (location == null) {
              info.add('No location yet!');
            } else {
              info.add('Lat: ${location!.latitude.toStringAsFixed(4)}, Lng: ${location!.longitude.toStringAsFixed(4)}');
            }
          }
        }
      });
    if (info == []){
      return ['No Info'];
    } else {
      print('Gathered Information: $info');
      return info;
    }
  }

}