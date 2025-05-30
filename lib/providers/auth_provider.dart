import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_TUKLAS/api/storage_api.dart';
import '../api/firebase_auth_api.dart';

class UserAuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> userStream;
  final StorageApi storageService = StorageApi();

  UserAuthProvider() {
    authService = FirebaseAuthAPI();
    userStream = authService.getUserStream();
  }

  String getCurrentUserId() {
    return authService.getCurrentUserId();
  }

  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    String message = await authService.signIn(email, password);
    notifyListeners();
    return message;
  }

  Future<String> signUp(String email, String username, String password) async {
    String message = await authService.signUp(email, username, password);
    notifyListeners();
    return message;
  }

  Future<void> signOut(String email, String password) async {
    await authService.signOut();
    notifyListeners();
  }

  Future<bool> checkUsername(String username) async {
    bool exists = await authService.checkUsername(username);
    notifyListeners();
    return exists;
  }

  Future<String> findEmail(String username) async {
    String? email = await authService.findEmail(username);
    notifyListeners();
    return email!;
  }

  // method to upload image to Firebase Storage
  // Future<void> uploadUserImage(dynamic image, String username) async {
  //   final message = await storageService.uploadImage(image, username);
  //   print(message);
  //   notifyListeners();
  // }
}
