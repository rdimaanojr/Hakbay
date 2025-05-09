import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hakbay/api/firebase_user_api.dart';
import 'package:hakbay/firebase_options.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/utils/logger.dart';

void main() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    logger.i("Firebase initialized successfully.");
  } catch (e) {
    logger.e("Error initializing Firebase", error: e);
    return; // Exit if Firebase fails to initialize
  }
  // Create an instance of FirebaseUserAPI
  final userAPI = FirebaseUserAPI();

  // Test data
  const testUID = "testUID123";
  final testUser = {
    "username": "testuser",
    "email": "testuser@example.com",
    "fname": "Test",
    "lname": "User",
    "phone": "1234567890",
    "profilePic": "",
    "interests": ["coding", "reading"],
    "travelStyles": ["adventure", "relaxation"],
    "isPrivate": false,
  };

  // Test saveUser
  logger.d("Testing saveUser...");
  final saveUserResult = await userAPI.saveUser(testUID, testUser);
  logger.i("saveUser result: $saveUserResult");
}