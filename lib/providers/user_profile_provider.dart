import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_TUKLAS/api/user_profile_api.dart';
import 'package:project_TUKLAS/models/matched_user_model.dart';
import 'package:project_TUKLAS/models/user_profile_model.dart';

class UserProfileProvider with ChangeNotifier {
  final FirebaseUserProfileApi firebaseService = FirebaseUserProfileApi();
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userProfileStream;
  UserProfile? _currentUserProfile;
  List<MatchedUser> _similarUsers = [];

  List<MatchedUser> get similarUsers => _similarUsers;
  UserProfile? get currentUserProfile => _currentUserProfile;

  UserProfileProvider() {
    _initialize();
  }

  void _initialize() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userProfileStream = firebaseService.getUserProfileStream();
      // Listen to profile changes and update similar users
      _userProfileStream?.listen((snapshot) async {
        if (snapshot.exists) {
          _currentUserProfile = UserProfile.fromJson(
            snapshot.data()!,
            snapshot.id,
          );
          await calculateAndSetSimilarUsers();
        }
      });
    } else {
      _userProfileStream = Stream.empty();
    }
    notifyListeners();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> get userProfileStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(
        FirebaseFirestore.instance.doc('users/__nouser__').snapshots().first
            as DocumentSnapshot<Map<String, dynamic>>,
      );
    }
    return firebaseService.getUserProfileStream();
  }

  // Method to update the user profile
  Future<void> updateProfile(UserProfile profile) async {
    final message = await firebaseService.updateUserProfile(
      username: profile.username,
      firstName: profile.firstName,
      lastName: profile.lastName,
      styles: profile.styles,
      interests: profile.interests,
      phoneNumber: profile.phone,
      isPublic: profile.isPublic,
    );
    print(message);  }

  Future<void> createInitialProfile(
    String username,
    String firstName,
    String lastName,
    {String? phone, bool isPublic = false}) async {
    await firebaseService.createUserProfile(
      username: username,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phone,
      isPublic: isPublic,
    );
    await loadCurrentUserProfile();
    notifyListeners();
  }


  // Fetch and store current user profile
  Future<UserProfile?> loadCurrentUserProfile() async {
    try {
      _currentUserProfile = await firebaseService.getUserProfileOnce();
      await calculateAndSetSimilarUsers(); // Recalculate similar users when profile is loaded
      notifyListeners();
      return _currentUserProfile;
    } catch (e) {
      print("Error fetching current user profile: $e");
      _currentUserProfile = null;
      notifyListeners();
      return null;
    }
  }

  // Fetches current user profile once, does not store in provider state by default
  Future<UserProfile> fetchUserProfileOnce() async {
    return await firebaseService.getUserProfileOnce();
  }

  Future<void> updateStyles(List<String> styles, String username) async {
    await firebaseService.editUserStyles(styles, username);
    // Profile will be updated through the stream listener
  }

  Future<void> updateInterests(List<String> interests, String username) async {
    await firebaseService.editUserInterests(interests, username);
    // Profile will be updated through the stream listener
  }

  Future<List<UserProfile>> getAllOtherUsers() async {
    return await firebaseService.getAllOtherUsers();
  }

  // This method now fetches the data, then calls the algorithm
  Future<void> calculateAndSetSimilarUsers() async {
    try {
      // Ensure current user profile is loaded
      final currentUser = _currentUserProfile ?? await loadCurrentUserProfile();
      if (currentUser == null) {
        print("Current user profile is not available.");
        _similarUsers = [];
        notifyListeners();
        return;
      }

      final List<UserProfile> allOtherUsers =
          await firebaseService.getAllOtherUsers();
      _similarUsers = firebaseService.findSimilarUsersAlgorithm(
        currentUser,
        allOtherUsers,
      );
      notifyListeners();
    } catch (e) {
      print("Error calculating similar users: $e");
      _similarUsers = [];
      notifyListeners();
    }
  }

  //method to update profile image as base64 in Firestore
  Future<bool> updateProfileImage(String imageBase64, String username) async {
    try {
      final api = FirebaseUserProfileApi();
      final result = await api.updateUserProfileImage(imageBase64, username);

      // Log result for debugging
      print('updateUserProfileImage API result: $result');

      // Define success condition robustly (e.g., case-insensitive contains 'success')
      final isSuccess = result.toLowerCase().contains('success');

      if (isSuccess) {
        await loadCurrentUserProfile(); // Reload profile data after update
        notifyListeners();              // Notify UI of changes
        return true;
      } else {
        print('Failed to update profile image: $result');
        return false;
      }
    } catch (e, stacktrace) {
      print('Exception in updateProfileImage: $e');
      print(stacktrace);
      return false;
    }
  }

  Future<String> sendBuddyReq(String uid, String buddyUid) async {
    String msg = await firebaseService.sendBuddyReq(uid, buddyUid);
    notifyListeners();
    return msg;
  }

  Future<String> processRequest(String buddyUid, bool accept) async {
    String msg = await firebaseService.processRequest(buddyUid, accept);
    notifyListeners();
    return msg;
  }

  Future<String?> findName(String username) async {
    String? name = await firebaseService.findName(username);
    notifyListeners();
    return name!;
  }

  Future<String?> findId(String username) async {
    String? id = await firebaseService.findId(username);
    notifyListeners();
    return id!;
  }

  Stream<QuerySnapshot> getAllBuddies(String userId) {
    Stream<QuerySnapshot> buddies = firebaseService.getAllBuddies(userId);
    notifyListeners();
    print(buddies);
    return buddies;
  }

  Stream<QuerySnapshot> getAllRequests(String userId) {
    Stream<QuerySnapshot> requests = firebaseService.getAllRequests(userId);
    notifyListeners();
    print(requests);
    return requests;
  }
}
