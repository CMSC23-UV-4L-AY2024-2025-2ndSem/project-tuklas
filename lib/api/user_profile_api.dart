import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileAPI {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAllUsers() {
    return db.collection('users').snapshots();
  }

  Future<String> editUserStyles(List<String> travelStyles, String username) async {
    try {
      final user = await db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

      if (user.docs.isNotEmpty){
        final docRef = user.docs.first.reference;

        await docRef.update({
          'styles': travelStyles,
        });
      }
      
      return 'Success!';
    } on FirebaseException catch (e) {
      return 'Error on ${e.code}: ${e.message}';
    }
  }

  Future<String> editUserInterests(List<String> interests, String username) async {
    try {
      final user = await db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

      if (user.docs.isNotEmpty){
        final docRef = user.docs.first.reference;

        await docRef.update({
          'interests': interests,
        });
      }
      
      return 'Success!';
    } on FirebaseException catch (e) {
      return 'Error on ${e.code}: ${e.message}';
    }
  }

}