import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_TUKLAS/models/matched_user_model.dart';
import 'package:project_TUKLAS/models/user_profile_model.dart';

class FirebaseUserProfileApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user profile stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(
        _firestore.doc('users/__nouser__').snapshots().first
            as DocumentSnapshot<Map<String, dynamic>>,
      );
    }
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // Get user profile once
  Future<UserProfile> getUserProfileOnce() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      throw Exception('User profile not found');
    }

    return UserProfile.fromJson(doc.data()!, user.uid);
  }

  // Get all other users (excluding current user)
  Future<List<UserProfile>> getAllOtherUsers() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    final querySnapshot =
        await _firestore
            .collection('users')
            .where(FieldPath.documentId, isNotEqualTo: currentUser.uid)
            .get();

    return querySnapshot.docs
        .map((doc) => UserProfile.fromJson(doc.data(), doc.id))
        .toList();
  }

  // Find similar users based on interests and styles
  List<MatchedUser> findSimilarUsersAlgorithm(
    UserProfile currentUser,
    List<UserProfile> allUsers,
  ) {
    final List<MatchedUser> matchedUsers = [];

    for (final user in allUsers) {
      int matchCount = 0;

      // Compare interests
      if (currentUser.interests != null && user.interests != null) {
        for (final interest in currentUser.interests!) {
          if (user.interests!.contains(interest)) {
            matchCount++;
          }
        }
      }

      // Compare styles
      if (currentUser.styles != null && user.styles != null) {
        for (final style in currentUser.styles!) {
          if (user.styles!.contains(style)) {
            matchCount++;
          }
        }
      }

      // Only add users with at least one match
      if (matchCount > 0) {
        matchedUsers.add(MatchedUser(user: user, matchCount: matchCount));
      }
    }

    // Sort by match count in descending order
    matchedUsers.sort((a, b) => b.matchCount.compareTo(a.matchCount));
    return matchedUsers;
  }

  // Update user profile
  Future<String> updateUserProfile({
    required String username,
    required String firstName,
    required String lastName,
    List<String>? styles,
    List<String>? interests,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'No user logged in';
      }

      await _firestore.collection('users').doc(user.uid).update({
        'username': username,
        'fname': firstName,
        'lname': lastName,
        if (styles != null) 'styles': styles,
        if (interests != null) 'interests': interests,
      });
      return 'Profile updated successfully';
    } catch (e) {
      return 'Error updating profile: $e';
    }
  }

  Future<String> updateUserProfileImage(
    String base64Image,
    String username,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'No user logged in';
      }

      await _firestore.collection('users').doc(user.uid).update({
        'imageBase64': base64Image,
      });
      return 'Profile image updated successfully';
    } catch (e) {
      return 'Error updating profile image: $e';
    }
  }

  // Create initial user profile
  Future<void> createUserProfile({
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'username': username,
      'fname': firstName,
      'lname': lastName,
      'styles': <String>[],
      'interests': <String>[],
    });
  }

  // Edit user styles
  Future<void> editUserStyles(List<String> styles, String username) async {
    try {
      final userQuery =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      if (userQuery.docs.isNotEmpty) {
        await userQuery.docs.first.reference.update({'styles': styles});
      }
    } catch (e) {
      print('Error updating styles: $e');
      rethrow;
    }
  }

  // Edit user interests
  Future<void> editUserInterests(
    List<String> interests,
    String username,
  ) async {
    try {
      final userQuery =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      if (userQuery.docs.isNotEmpty) {
        await userQuery.docs.first.reference.update({'interests': interests});
      }
    } catch (e) {
      print('Error updating interests: $e');
      rethrow;
    }
  }

  // method to update user profile image base64 in Firestore
  Future<void> updateProfileImage(String base64Image, String username) async {
    try {
      final userQuery =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      if (userQuery.docs.isNotEmpty) {
        await userQuery.docs.first.reference.update({
          'profileImage': base64Image,
        });
      }
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow;
    }
  }

  Future<String> sendBuddyReq(String uid, String buddyUser) async {
    Map<String, dynamic> req = {
      'username': buddyUser
    };
    String? msg;
    try {
      String? buddyUid = await findId(buddyUser);
      await FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('buddies')
      .where('username', isEqualTo: buddyUser)
      .limit(1)
      .get()
      .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.docs.isEmpty) {
          await _firestore.collection('users').doc(buddyUid).collection('requests').doc(buddyUid).set(req);
          msg = 'Successfully sent request!';
        } else {
          msg = 'Already friends with user!';
        }
        print (msg);
        return msg;
      });
    } on FirebaseException catch (e) {
      msg = 'Error on ${e.code}: ${e.message}';
    }
    return msg!;
  }

  Future<String> processRequest(String buddyUid, bool accept) async {
    final user = _auth.currentUser;
    try {
      if (accept){
        await _firestore.collection('users').doc(buddyUid).collection('buddies').doc(user!.uid).set({'id': user.uid});
        await _firestore.collection('users').doc(user.uid).collection('buddies').doc(buddyUid).set({'id': buddyUid});
      }
      await _firestore.collection('users').doc(user!.uid).collection('requests').doc(buddyUid).delete();
      return "Success!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }

  Stream<QuerySnapshot> getAllBuddies(uid) {
    return _firestore.collection('users').doc(uid).collection('buddies').snapshots();
  }

   Stream<QuerySnapshot> getAllRequests(uid) {
    return _firestore.collection('users').doc(uid).collection('requests').snapshots();
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

  Future<String?> findId(String username) async {
    String? id;
    await FirebaseFirestore
      .instance // snapshot of db with usernames similar to username
      .collection('users')
      .where('username', isEqualTo: username)
      .limit(1)
      .get()
      .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          id = null;
        } else {
          id = querySnapshot.docs[0]['id'];
        }
      });
    return id;
  }
}
