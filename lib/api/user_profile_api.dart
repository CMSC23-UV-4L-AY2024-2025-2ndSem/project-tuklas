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

  Future<String> addFriend(String uid, String friendUser) async {
    Map<String, dynamic> friend = {
      'name': '',
      'username': friendUser
    };
    String? msg;
    try {
      await FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('friends')
      .where('username', isEqualTo: friendUser)
      .limit(1)
      .get()
      .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.docs.isEmpty) {
          friend['id'] = db.collection('users').doc().id;
          await db.collection('users').doc(uid).collection('friends').doc(friend['id']).set(friend);
          msg = 'Successfully added friend!';
        } else {
          msg = 'Already friends with user!';
        }
        return msg;
      });
    } on FirebaseException catch (e) {
      msg = 'Error on ${e.code}: ${e.message}';
    }
    return msg!;
  }

  Stream<QuerySnapshot> getAllFriends(uid) {
    return db.collection('users').doc(uid).collection('friends').snapshots();
  }

  Future<String?> findName(String username) async {
    String? name;
    await FirebaseFirestore
      .instance // snapshot of db with usernames similar to username
      .collection('users')
      .where('username', isEqualTo: username)
      .limit(1)
      .get()
      .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          name = null;
        } else {
          name = querySnapshot.docs[0]['fname'] + querySnapshot.docs[0]['lname'];
        }
      });
    return name;
  }
}