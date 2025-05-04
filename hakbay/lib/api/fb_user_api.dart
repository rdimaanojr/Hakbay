import 'package:cloud_firestore/cloud_firestore.dart';

// This API manages our users collection data
class FirebaseUserAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Save the new user in the database
  Future<String> saveUser(String uid, Map<String, dynamic> user) async {
    try {
      // Save user with the UID
      await db.collection('users').doc(uid).set(user);
      return "Successfully saved user!";
    } on FirebaseException catch (e) {
      return 'Error on ${e.message}';
    }
  }

  // Check if a username already exists in the database
  Future<bool> isUsernameTaken(String username) async {
    try {
      final querySnapshot = await db
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      return querySnapshot.docs.isNotEmpty; // Returns true if username exists
    } on FirebaseException catch (e) {
      print('Error checking username: ${e.message}');
      return false; 
    }
  }

  // Get email by the username
  Future<String> getEmailByUsername(String username) async {
    try {
      final querySnapshot = await db
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['email']; // Return the email if found
      }
      return "";
    } on FirebaseException catch (e) {
      print('Error retrieving email by username: ${e.message}');
      return "";
    }
  }

  // Get user data by UID
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final docSnapshot = await db.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        print("User not found");
        return null;
      }
    } on FirebaseException catch (e) {
      print('Error retrieving user data: ${e.message}');
      return null;
    }
  }
}