import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';

// This API manages our users collection data
class FirebaseUserAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Save the new user in the database
  Future<String> saveUser(String uid, Map<String, dynamic> user) async {
    try {
      logger.d("Saving user with UID: $uid and data: $user");
      await db.collection('users').doc(uid).set(user);
      return "Successfully saved user!";
    } on FirebaseException catch (e) {
      logger.e("Error saving user to Firestore", error: e);
      return 'Error on ${e.message}';
    }
  }

  Stream<QuerySnapshot> fetchSharedUsers(List<String> uids) {
    if(uids.isEmpty) return Stream.empty();

    return db.collection('users').where(FieldPath.documentId, whereIn: uids).snapshots();
  }

  // Check if a username already exists in the database
  Future<bool> isUsernameTaken(String username) async {
    try {
      final querySnapshot =
          await db
              .collection('users')
              .where('username', isEqualTo: username)
              .get();

      return querySnapshot.docs.isNotEmpty; // Returns true if username exists
    } on FirebaseException catch (e) {
      logger.e("Error checking username", error: e);
      return false;
    }
  }

  // Get email by the username
  Future<String> getEmailByUsername(String username) async {
    try {
      final querySnapshot =
          await db
              .collection('users')
              .where('username', isEqualTo: username)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['email']; // Return the email if found
      }
      return "";
    } on FirebaseException catch (e) {
      logger.e("Error retrieving email by username", error: e);
      return "";
    }
  }

  // Return the UID of the current user
  // returns null if the user is not logged in
  Future<String?> getCurrentUserUID() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return user?.uid;
    } on FirebaseException catch (e) {
      logger.e("Error retrieving current user UID", error: e);
      return null;
    }
  }

  // Get user data by UID
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final docSnapshot = await db.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        logger.w("User with UID $uid does not exist");
        return null;
      }
    } on FirebaseException catch (e) {
      logger.e("Error retrieving user data", error: e);
      return null;
    }
  }

  // Update user data in the database
  Future<void> updateUser({
    required String uid,
    String? fname,
    String? lname,
    String? phone,
    String? profilePic,
    List<String>? interests,
    List<String>? travelStyles,
    bool? isPrivate,
  }) async {
    try {
      // updated user data
      final updatedData = <String, dynamic>{};
      if (fname != null) updatedData['fname'] = fname;
      if (lname != null) updatedData['lname'] = lname;
      if (phone != null) updatedData['phone'] = phone;
      if (interests != null) updatedData['interests'] = interests;
      if (travelStyles != null) updatedData['travelStyles'] = travelStyles;
      if (isPrivate != null) updatedData['isPrivate'] = isPrivate;

      // Update the user document with the new data
      await db.collection('users').doc(uid).update(updatedData);

      logger.i("User data updated successfully");
    } on FirebaseException catch (e) {
      logger.e("Error updating user data", error: e);
    }
  }

  Future<void> updateUserProfilePic(String uid, String base64Image) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profilePic': base64Image,
      });
      logger.i("Profile picture updated successfully");
    } catch (e) {
      logger.e("Error updating profile picture", error: e);
    }
  }

  Future<List<Map<String, dynamic>>> getSimilarUsers(String userId) async {
    try {
      // Get current user's data
      final currentUserDoc = await db.collection('users').doc(userId).get();
      if (!currentUserDoc.exists) {
        throw 'User not found';
      }

      final currentUserData = currentUserDoc.data()!;
      final currentUserInterests = List<String>.from(
        currentUserData['interests'] ?? [],
      );
      final currentUserStyles = List<String>.from(
        currentUserData['travelStyles'] ?? [],
      );

      // Get all users
      final usersQuery = await db.collection('users').get();

      // Filter and map to raw data
      final similarUsers =
          usersQuery.docs
              .where((doc) {
                if (doc.id == userId) return false;

                final userData = doc.data();
                final userInterests = List<String>.from(
                  userData['interests'] ?? [],
                );
                final userStyles = List<String>.from(
                  userData['travelStyles'] ?? [],
                );
                final isPrivate = userData['isPrivate'];

                // Check for any common interests or styles or not private
                return (userInterests.any(
                          (i) => currentUserInterests.contains(i),
                        ) ||
                        userStyles.any((s) => currentUserStyles.contains(s))) &&
                    !isPrivate;
              })
              .map((doc) => doc.data())
              .toList();

      return similarUsers;
    } catch (e) {
      logger.e('Error getting similar users: $e');
      rethrow;
    }
  }
}
