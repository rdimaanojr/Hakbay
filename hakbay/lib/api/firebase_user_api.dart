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

  Future<String> getCurrentUserUID() async {
    try {
      final user = await db.collection('users').doc().get();
      return user.id; // Return the UID of the current user
    } on FirebaseException catch (e) {
      print('Error retrieving current user UID: ${e.message}');
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

  // Update user data in the database
  Future<void> updateUser(String uid, String fname, String lname, String phone, List<String> interests, List<String> travelStyles, bool isPrivate) async {
    try {
      await db.collection('users').doc(uid).update({
        'fname': fname,
        'lname': lname,
        'phone': phone,
        'interests': interests,
        'travelStyles': travelStyles,
        'isPrivate': isPrivate,
      });
      print("User data updated successfully!");
    } on FirebaseException catch (e) {
      print('Error updating user data: ${e.message}');
    }
  }

  Future<void> updateUserProfilePic(String uid, String base64Image) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'profilePic': base64Image});
      print("Profile picture updated in Firestore"); 
    } catch (e) {
      print("Error updating profile picture: $e");
    }
  }
}
