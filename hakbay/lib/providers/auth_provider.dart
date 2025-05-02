import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hakbay/api/fb_auth_api.dart';

class UserAuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> userStream;

  UserAuthProvider() {
    authService = FirebaseAuthAPI();
    userStream = authService.getUserStream();
  }

  String? getCurrentUserUID() {
    return authService.getCurrentUserUID();
  } 

  Future<String> signIn(String email, String password) async {
    String message = await authService.signIn(email, password);
    notifyListeners();
    return message;
  }

  Future<String> signUp(String email, String password) async {
    String message = await authService.signUp(email, password);
    notifyListeners();
    return message;
  }

  Future<String> signOut() async {
    await authService.signOut();
    notifyListeners();
    return "Succesfully signed out!";
  }
}