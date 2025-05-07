import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_TUKLAS/models/user_profile_model.dart';

class FirebaseUserProfileApi {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Get the current user's profile stream
  Stream<DocumentSnapshot> getUserProfileStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    return db.collection('users').doc(uid).snapshots();
  }

  // Update the user's profile
  Future<String> updateUserProfile({
    required String username,
    required String name,
    List<String>? styles,
    List<String>? interests,
    String? imageBase64,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return 'User not logged in';

      final docRef = db.collection('users').doc(uid);

      await docRef.update({
        'username': username,
        'name': name,
        'styles': styles ?? [],
        'interests': interests ?? [],
        'imageBase64': imageBase64,
      });

      return 'Profile updated successfully!';
    } on FirebaseException catch (e) {
      return 'Error on ${e.code}: ${e.message}';
    }
  }

  // Create a new user profile (if needed)
  Future<void> createUserProfile({
    required String username,
    required String name,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    final userDoc = db.collection('users').doc(uid);

    await userDoc.set({
      'username': username,
      'name': name,
      'styles': [],
      'interests': [],
      'imageBase64': null,
    });
  }

  Future<UserProfile> getUserProfileOnce() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    final doc = await db.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('User profile not found');

    return UserProfile.fromJson(doc.data()!);
  }

  Future<void> editUserStyles(List<String> styles, String username) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userDoc.update({'styles': styles});
  }

  Future<void> editUserInterests(List<String> interests, String username) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userDoc.update({'interests': interests});
  }

}
