import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_TUKLAS/models/matched_user_model.dart';
import 'package:project_TUKLAS/models/user_profile_model.dart';
import 'package:project_TUKLAS/screens/buddy_requests_screen.dart';

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
    required String lastName, required bool isPublic, String? phoneNumber,
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
  Future<String> updateProfileImage(String imageBase64,) async {
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
    try {
      QuerySnapshot existingBuddy = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('buddies')
          .where('id', isEqualTo: buddyUid)
          .limit(1)
          .get();

      if (existingBuddy.docs.isNotEmpty) {
        return 'Already friends with user!';
      }

      // Send the buddy request
      await FirebaseFirestore.instance
          .collection('users')
          .doc(buddyUid)
          .collection('requests')
          .doc(uid)
          .set({'id': uid});

      return 'Successfully sent request!';
    } catch (e) {
      print('Error sending buddy request: $e');
      return 'An error occurred while sending the request.';
    }
  }

  Future<String> processRequest(String buddyUid, bool accept) async {
    final user = _auth.currentUser;
    final buddy = {
      'id': buddyUid,
    };
    final userInf = {
      'id': user!.uid,
    };
    try {
      if (accept){
        await _firestore.collection('users').doc(buddyUid).collection('buddies').doc(user.uid).set(userInf);
        await _firestore.collection('users').doc(user.uid).collection('buddies').doc(buddyUid).set(buddy);
      }
      await _firestore.collection('users').doc(user.uid).collection('requests').doc(buddyUid).delete();
      return "Success!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }

  Future<List<UserRequest>> getBuddyRequests(String currentUserId) async {
    final requestSnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('requests')
        .get();

    List<UserRequest> requests = [];

    for (var requestDoc in requestSnapshot.docs) {
      final senderId = requestDoc.data()['id'];

      final userDoc = await _firestore.collection('users').doc(senderId).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        requests.add(UserRequest(
          id: senderId,
          name: data['name'] ?? 'Unknown',
          username: data['username'] ?? '',
          avatarUrl: data['avatarUrl'],
        ));
      }
    }
    return requests;
  }

  Future<List<UserRequest>> getTravelBuddies(String currentUserId) async {
    final buddiesSnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('buddies')
        .get();

    List<UserRequest> buddies = [];

    for (var buddyDoc in buddiesSnapshot.docs) {
      final buddyId = buddyDoc.id;

      final userDoc = await _firestore.collection('users').doc(buddyId).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        buddies.add(UserRequest(
          id: buddyId,
          name: data['name'] ?? 'Unknown',
          username: data['username'] ?? '',
          avatarUrl: data['avatarUrl'],
        ));
      }
    }

    return buddies;
  }

  Future<String?> findName(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        final fname = data?['fname'] as String?;
        final lname = data?['lname'] as String?;
        if (fname != null && lname != null) {
          return '$fname $lname';
        }
      } else {
        print('User document does not exist.');
      }
      return null;
    } catch (e) {
      print('Error retrieving name: $e');
      return null;
    }
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
    final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('id', isEqualTo: uid)
      .limit(1)
      .get();

    if (querySnapshot.docs.isEmpty) return null;

    return querySnapshot.docs[0]['username'];
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }
}
