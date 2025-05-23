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
    required String phoneNumber,
    required bool isPublic, // 👈 add this
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
        'phoneNumber': phoneNumber,
        'isPublic': isPublic,
        if (styles != null) 'styles': styles,
        if (interests != null) 'interests': interests,
      });
      return 'Profile updated successfully';
    } catch (e) {
      return 'Error updating profile: $e';
    }
  }

  Future<String> updateUserProfileImage(
    String imageBase64,
    String username,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'No user logged in';
      }

      await _firestore.collection('users').doc(user.uid).update({
        'imageBase64': imageBase64,
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
    required bool isPublic,
    String? phoneNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'username': username,
      'fname': firstName,
      'lname': lastName,
      'isPublic': isPublic,
      'phone': phoneNumber ?? '',
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
  Future<String> updateProfileImage(String imageBase64) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'No user logged in';
      }

      await _firestore.collection('users').doc(user.uid).update({
        'imageBase64': imageBase64,
      });

      return 'Profile image updated successfully';
    } catch (e) {
      return 'Error updating profile image: $e';
    }
  }

  Future<String> sendBuddyReq(String uid, String buddyUid) async {
    Map<String, dynamic> req = {
      'id': uid,
      'username': await findUsername(uid),
      'name': await findName(uid),
    };
    String? msg;
    try {
      String? buddyUser = await findId(buddyUid);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('buddies')
          .where('username', isEqualTo: buddyUser)
          .limit(1)
          .get()
          .then((QuerySnapshot querySnapshot) async {
            if (querySnapshot.docs.isEmpty) {
              await _firestore
                  .collection('users')
                  .doc(buddyUid)
                  .collection('requests')
                  .doc(uid)
                  .set(req);
              msg = 'Successfully sent request!';
            } else {
              msg = 'Already friends with user!';
            }
            print(msg);
            return msg;
          });
    } on FirebaseException catch (e) {
      msg = 'Error on ${e.code}: ${e.message}';
    }
    return msg!;
  }

  Future<String> processRequest(String buddyUid, bool accept) async {
    final user = _auth.currentUser;
    final buddy = {
      'id': buddyUid,
      'username': await findUsername(buddyUid),
      'name': await findName(buddyUid),
    };
    final userInf = {
      'id': user!.uid,
      'username': await findUsername(user.uid),
      'name': await findName(user.uid),
    };
    try {
      if (accept) {
        await _firestore
            .collection('users')
            .doc(buddyUid)
            .collection('buddies')
            .doc(user.uid)
            .set(userInf);
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('buddies')
            .doc(buddyUid)
            .set(buddy);
      }
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('requests')
          .doc(buddyUid)
          .delete();
      print(userInf["username"]);
      print(userInf["name"]);
      print(buddy["username"]);
      print(buddy["name"]);
      return "Success!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }

  Stream<QuerySnapshot> getAllBuddies(uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('buddies')
        .snapshots();
  }

  Stream<QuerySnapshot> getAllRequests(uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('requests')
        .snapshots();
  }

  Future<String?> findName(String uid) async {
    String? name;
    await FirebaseFirestore
        .instance // snapshot of db with usernames similar to username
        .collection('users')
        .where('id', isEqualTo: uid)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isEmpty) {
            name = null;
          } else {
            name =
                querySnapshot.docs[0]['fname'] +
                " " +
                querySnapshot.docs[0]['lname'];
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

  Future<String?> findUsername(String uid) async {
    String? username;
    await FirebaseFirestore
        .instance // snapshot of db with usernames similar to username
        .collection('users')
        .where('id', isEqualTo: uid)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isEmpty) {
            username = null;
          } else {
            username = querySnapshot.docs[0]['username'];
          }
        });
    return username;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }

  Future<void> addUserStyles(List<String> styles, String username) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    await userDoc.update({'styles': styles});
  }

  Future<void> addUserInterests(List<String> interests, String username) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    await userDoc.update({'interests': interests});
  }

  Future<void> addName(String username, String fName, String lName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    await userDoc.update({'fname': fName, 'lname': lName});
  }
}
