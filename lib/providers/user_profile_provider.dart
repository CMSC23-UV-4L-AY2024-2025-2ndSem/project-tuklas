import 'package:flutter/material.dart';
import '../api/user_profile_api.dart';

class UserProfileProvider with ChangeNotifier {
  late UserProfileAPI profileService;

  UserProfileProvider() {
    profileService = UserProfileAPI();
  }

  Future<String> editUserStyles(List<String> travelStyles, String username) async{
    String message = await profileService.editUserStyles(travelStyles, username);
    notifyListeners();
    return message;
  }

  Future<String> editUserInterests(List<String> interests, String username) async{
    String message = await profileService.editUserInterests(interests, username);
    notifyListeners();
    return message;
  }
}