import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hakbay/api/firebase_auth_api.dart';

class UserAuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> userStream;

  // Constructor to initialize the authService and userStream
  UserAuthProvider() {
    authService = FirebaseAuthAPI();
    userStream = authService.getUserStream();
  }

  // Get the current user
  String? getCurrentUserUID() {
    return authService.getCurrentUserUID();
  } 

  Future<User?> getCurrentUser() {
    return authService.getCurrentUser();
  }

  // Sign in the user
  Future<String> signIn(String email, String password) async {
    String message = await authService.signIn(email, password);
    notifyListeners();
    return message;
  }

  // Sign up a new user
  Future<String> signUp(String email, String password) async {
    String message = await authService.signUp(email, password);
    notifyListeners();
    return message;
  }

  // Sign out the user
  Future<String> signOut() async {
    await authService.signOut();
    notifyListeners();
    return "Succesfully signed out!";
  }
}