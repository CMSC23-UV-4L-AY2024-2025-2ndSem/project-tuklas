import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_TUKLAS/api/user_profile_api.dart';
import 'package:project_TUKLAS/models/user_profile_model.dart';

class UserProfileProvider with ChangeNotifier {
  final FirebaseUserProfileApi firebaseService = FirebaseUserProfileApi();
  late Stream<DocumentSnapshot> _userProfileStream;

  UserProfileProvider() {
    fetchUserProfile();
  }

  // Stream getter for user profile
  Stream<DocumentSnapshot<Map<String, dynamic>>> get userProfile {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Return an empty stream of the correct type if no user is logged in
      return FirebaseFirestore.instance
          .collection('users')
          .doc('__nouser__')
          .snapshots()
          .map((snapshot) => snapshot);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) => snapshot);
  }

  // Method to initialize stream
  void fetchUserProfile() {
    _userProfileStream = firebaseService.getUserProfileStream();
    notifyListeners();
  }

  // Method to update the user profile
  Future<void> updateProfile(UserProfile profile) async {
    final message = await firebaseService.updateUserProfile(
      username: profile.username,
      name: profile.name,
      styles: profile.styles,
      interests: profile.interests,
    );
    print(message);
    notifyListeners();
  }

  // Optional: create user profile when registering
  Future<void> createInitialProfile(String username, String name) async {
    await firebaseService.createUserProfile(username: username, name: name);
    notifyListeners();
  }

  Future<UserProfile> fetchUserProfileOnce() async {
    return await firebaseService.getUserProfileOnce();
  }

  Future<void> updateStyles(List<String> styles, String username) async {
    await firebaseService.editUserStyles(styles, username);
    notifyListeners();
  }

  Future<void> updateInterests(List<String> interests, String username) async {
    await firebaseService.editUserInterests(interests, username);
    notifyListeners();
  }
}
