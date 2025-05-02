import 'package:flutter/material.dart';
import 'package:hakbay/api/fb_user_api.dart';
import 'package:hakbay/models/user_model.dart';

// Our provider class
class UserProvider with ChangeNotifier {
  late FirebaseUserAPI userAPI = FirebaseUserAPI();

  // Save a new user and store it in Firestore
  Future<void> saveUser(String uid, AppUser user) async {
    String message = await userAPI.saveUser(uid, user.toJson());
    print(message);
  }
  
  // Check if a username is already taken
  Future<bool> isUsernameTaken(String username) async {
    return await userAPI.isUsernameTaken(username);
  }
  
  // Get email by username
  Future<String> getEmailByUsername(String username) async {
    return await userAPI.getEmailByUsername(username);
  }
  

}