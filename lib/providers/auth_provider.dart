import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../api/firebase_auth_api.dart';

class UserAuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> userStream;

  UserAuthProvider() {
    authService = FirebaseAuthAPI();
    userStream = authService.getUserStream();
  }

  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    String message = await authService.signIn(email, password);
    notifyListeners();
    return message;
  }

  Future<String> signUp(
    String email,
    String password,
    String fName,
    String lName,
    String uName,
  ) async {
    String message = await authService.signUp(
      email,
      password,
      fName,
      lName,
      uName,
    );
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
}
