import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hakbay/models/user_model.dart';
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

  // Get uid by the username
  Future<String?> getUidByUsername(String username) async {
    try {
      final querySnapshot =
          await db
              .collection('users')
              .where('username', isEqualTo: username)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['uid']; // Return the uid if found
      }
      return null;
    } on FirebaseException catch (e) {
      logger.e("Error retrieving email by username", error: e);
      return null;
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

  Future<AppUser?> getUserbyUid(String uid) async {
    try {
      final docSnapshot = await db.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return AppUser.fromJson(docSnapshot.data()!);
      } else {
        logger.w("User with UID $uid does not exist");
        return null;
      }
    } on FirebaseException catch (e) {
      logger.e("Error retrieving user data", error: e);
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

  // Friend System Methods
  Future<String> sendFriendRequest(String senderId, String receiverId) async {
    try {
      // Check if users exist
      final senderDoc = await db.collection('users').doc(senderId).get();
      final receiverDoc = await db.collection('users').doc(receiverId).get();
      
      if (!senderDoc.exists || !receiverDoc.exists) {
        throw 'One or both users do not exist';
      }

      // Check if they're already friends
      final senderData = senderDoc.data()!;
      if (senderData['friends']?.contains(receiverId) ?? false) {
        throw 'Already friends with this user';
      }

      // Check if there's already a pending request
      if (senderData['outgoingFriendRequests']?.contains(receiverId) ?? false) {
        throw 'Friend request already sent';
      }
      if (senderData['incomingFriendRequests']?.contains(receiverId) ?? false) {
        throw 'This user has already sent you a friend request';
      }

      // Add to outgoing requests for sender and incoming requests for receiver
      await db.collection('users').doc(senderId).update({
        'outgoingFriendRequests': FieldValue.arrayUnion([receiverId])
      });
      await db.collection('users').doc(receiverId).update({
        'incomingFriendRequests': FieldValue.arrayUnion([senderId])
      });

      logger.d('Friend request sent: $senderId -> $receiverId');
      return 'Friend request sent successfully';
    } catch (e) {
      logger.e('Error sending friend request', error: e);
      rethrow;
    }
  }

  Future<String> acceptFriendRequest(String userId, String requesterId) async {
    try {
      // Check if users exist
      final userDoc = await db.collection('users').doc(userId).get();
      final requesterDoc = await db.collection('users').doc(requesterId).get();
      
      if (!userDoc.exists || !requesterDoc.exists) {
        throw 'One or both users do not exist';
      }

      // Check if request exists
      final userData = userDoc.data()!;
      if (!(userData['incomingFriendRequests']?.contains(requesterId) ?? false)) {
        throw 'No friend request from this user';
      }

      // Add each other as friends
      await db.collection('users').doc(userId).update({
        'friends': FieldValue.arrayUnion([requesterId])
      });
      await db.collection('users').doc(requesterId).update({
        'friends': FieldValue.arrayUnion([userId])
      });

      // Remove from request lists
      await db.collection('users').doc(userId).update({
        'incomingFriendRequests': FieldValue.arrayRemove([requesterId])
      });
      await db.collection('users').doc(requesterId).update({
        'outgoingFriendRequests': FieldValue.arrayRemove([userId])
      });

      logger.d('Friend request accepted: $requesterId -> $userId');
      return 'Friend request accepted';
    } catch (e) {
      logger.e('Error accepting friend request', error: e);
      rethrow;
    }
  }

  Future<String> rejectFriendRequest(String receiverId, String senderId) async {
    try {
      // Check if users exist
      final receiverDoc = await db.collection('users').doc(receiverId).get();
      final senderDoc = await db.collection('users').doc(senderId).get();
      
      if (!receiverDoc.exists || !senderDoc.exists) {
        throw 'One or both users do not exist';
      }

      // Check if request exists
      final receiverData = receiverDoc.data()!;
      if (!(receiverData['incomingFriendRequests']?.contains(senderId) ?? false)) {
        throw 'No friend request from this user';
      }

      // Remove from request lists
      await db.collection('users').doc(receiverId).update({
        'incomingFriendRequests': FieldValue.arrayRemove([senderId])
      });
      await db.collection('users').doc(senderId).update({
        'outgoingFriendRequests': FieldValue.arrayRemove([receiverId])
      });

      logger.d('Friend request rejected: $senderId -> $receiverId');
      return 'Friend request rejected';
    } catch (e) {
      logger.e('Error rejecting friend request', error: e);
      rethrow;
    }
  }

  Future<String> cancelFriendRequest(String senderId, String receiverId) async {
    try {
      // Check if users exist
      final senderDoc = await db.collection('users').doc(senderId).get();
      final receiverDoc = await db.collection('users').doc(receiverId).get();
      
      if (!senderDoc.exists || !receiverDoc.exists) {
        throw 'One or both users do not exist';
      }

      // Check if request exists
      final senderData = senderDoc.data()!;
      if (!(senderData['outgoingFriendRequests']?.contains(receiverId) ?? false)) {
        throw 'No outgoing friend request to this user';
      }

      // Remove from request lists
      await db.collection('users').doc(senderId).update({
        'outgoingFriendRequests': FieldValue.arrayRemove([receiverId])
      });
      await db.collection('users').doc(receiverId).update({
        'incomingFriendRequests': FieldValue.arrayRemove([senderId])
      });

      logger.d('Friend request cancelled: $senderId -> $receiverId');
      return 'Friend request cancelled';
    } catch (e) {
      logger.e('Error cancelling friend request', error: e);
      rethrow;
    }
  }

  Future<String> unfriend(String userId1, String userId2) async {
    try {
      // Check if users exist
      final user1Doc = await db.collection('users').doc(userId1).get();
      final user2Doc = await db.collection('users').doc(userId2).get();
      
      if (!user1Doc.exists || !user2Doc.exists) {
        throw 'One or both users do not exist';
      }

      // Check if they are friends
      final user1Data = user1Doc.data()!;
      if (!(user1Data['friends']?.contains(userId2) ?? false)) {
        throw 'Users are not friends';
      }

      // Remove each other from friends list
      await db.collection('users').doc(userId1).update({
        'friends': FieldValue.arrayRemove([userId2])
      });
      await db.collection('users').doc(userId2).update({
        'friends': FieldValue.arrayRemove([userId1])
      });

      return 'Unfriended successfully';
    } catch (e) {
      logger.e('Error unfriending user', error: e);
      rethrow;
    }
  }

  // Get friend status between two users
  Future<Map<String, dynamic>> getFriendStatus(String userId1, String userId2) async {
    try {
      final user1Doc = await db.collection('users').doc(userId1).get();
      if (!user1Doc.exists) {
        throw 'User not found';
      }

      final user1Data = user1Doc.data()!;
      final friends = List<String>.from(user1Data['friends'] ?? []);
      final outgoingRequests = List<String>.from(user1Data['outgoingFriendRequests'] ?? []);
      final incomingRequests = List<String>.from(user1Data['incomingFriendRequests'] ?? []);

      return {
        'areFriends': friends.contains(userId2),
        'hasOutgoingRequest': outgoingRequests.contains(userId2),
        'hasIncomingRequest': incomingRequests.contains(userId2),
      };
    } catch (e) {
      logger.e('Error getting friend status', error: e);
      rethrow;
    }
  }

  // Streams for friend system
  Stream<List<String>> getFriendsStream(String uid) {
    try {
      logger.d('Setting up friends stream for user: $uid');
      return db
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) {
              logger.w('User document does not exist for friends stream: $uid');
              return List<String>.empty();
            }
            final friends = List<String>.from(doc.data()?['friends'] ?? []);
            logger.d('Friends stream updated. Found ${friends.length} friends');
            return friends;
          })
          .handleError((error) {
            logger.e('Error in friends stream', error: error);
            return List<String>.empty();
          });
    } catch (e) {
      logger.e('Error setting up friends stream', error: e);
      return Stream.value(List<String>.empty());
    }
  }

  Stream<List<String>> getIncomingFriendRequestsStream(String uid) {
    try {
      logger.d('Setting up incoming friend requests stream for user: $uid');
      return db
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) {
              logger.w('User document does not exist for incoming requests stream: $uid');
              return List<String>.empty();
            }
            final requests = List<String>.from(doc.data()?['incomingFriendRequests'] ?? []);
            logger.d('Incoming requests stream updated. Found ${requests.length} requests');
            return requests;
          })
          .handleError((error) {
            logger.e('Error in incoming requests stream', error: error);
            return List<String>.empty();
          });
    } catch (e) {
      logger.e('Error setting up incoming requests stream', error: e);
      return Stream.value(List<String>.empty());
    }
  }

  Stream<List<String>> getOutgoingFriendRequestsStream(String uid) {
    try {
      logger.d('Setting up outgoing friend requests stream for user: $uid');
      return db
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) {
              logger.w('User document does not exist for outgoing requests stream: $uid');
              return List<String>.empty();
            }
            final requests = List<String>.from(doc.data()?['outgoingFriendRequests'] ?? []);
            logger.d('Outgoing requests stream updated. Found ${requests.length} requests');
            return requests;
          })
          .handleError((error) {
            logger.e('Error in outgoing requests stream', error: error);
            return List<String>.empty();
          });
    } catch (e) {
      logger.e('Error setting up outgoing requests stream', error: e);
      return Stream.value(List<String>.empty());
    }
  }

  Stream<List<Map<String, dynamic>>> getSimilarUsersStream(String uid) {
    try {
      return db
          .collection('users')
          .doc(uid)
          .snapshots()
          .asyncMap((doc) async {
            try {
              final userData = doc.data();
              if (userData == null) return List<Map<String, dynamic>>.empty();
              
              final interests = List<String>.from(userData['interests'] ?? []);
              final travelStyles = List<String>.from(userData['travelStyles'] ?? []);
              final friends = List<String>.from(userData['friends'] ?? []);
              
              if (interests.isEmpty && travelStyles.isEmpty) {
                return List<Map<String, dynamic>>.empty();
              }
              
              logger.d('Finding similar users for $uid with interests: $interests and travel styles: $travelStyles');
              logger.d('Excluding friends: $friends');
              
              // Combine interests and travel styles into a single array for querying
              final combinedPreferences = [...interests, ...travelStyles];
              
              // Query users who share any of the preferences
              final snapshot = await db
                  .collection('users')
                  .where('interests', arrayContainsAny: combinedPreferences)
                  .where(FieldPath.documentId, isNotEqualTo: uid)
                  .get();
              
              // Filter results to ensure they match both interests and travel styles
              // and are not already friends
              final similarUsers = snapshot.docs
                  .map((doc) => doc.data())
                  .where((userData) {
                    final userId = userData['uid'] as String?;
                    if (userId == null || friends.contains(userId)) {
                      return false; // Skip if no uid or already a friend
                    }

                    final userInterests = List<String>.from(userData['interests'] ?? []);
                    final userTravelStyles = List<String>.from(userData['travelStyles'] ?? []);
                    
                    // Check if user shares any interests
                    final hasMatchingInterests = interests.isEmpty || 
                        userInterests.any((interest) => interests.contains(interest));
                    
                    // Check if user shares any travel styles
                    final hasMatchingTravelStyles = travelStyles.isEmpty || 
                        userTravelStyles.any((style) => travelStyles.contains(style));
                    
                    return hasMatchingInterests && hasMatchingTravelStyles;
                  })
                  .toList();
              
              logger.d('Found ${similarUsers.length} similar users (excluding friends)');
              return similarUsers;
            } catch (e) {
              logger.e('Error getting similar users in stream', error: e);
              return List<Map<String, dynamic>>.empty();
            }
          })
          .handleError((error) {
            logger.e('Error in similar users stream', error: error);
            return List<Map<String, dynamic>>.empty();
          });
    } catch (e) {
      logger.e('Error setting up similar users stream', error: e);
      return Stream.value(List<Map<String, dynamic>>.empty());
    }
  }
}
