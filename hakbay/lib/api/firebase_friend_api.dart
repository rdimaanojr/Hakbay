import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';

class FirebaseFriendAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Add a friend request
  Future<String> addFriendRequest(String senderId, String receiverId) async {
    try {
      final requestId = db.collection('friend_requests').doc().id;
      final timestamp = DateTime.now();

      // start a batch
      final batch = db.batch();

      // create friend request document
      final friendRequestRef = db.collection('friend_requests').doc(requestId);
      batch.set(friendRequestRef, {
        'senderId': senderId,
        'receiverId': receiverId,
        'timestamp': timestamp,
      });

      // update outgoing and incoming friend requests
      final senderRef = db.collection('users').doc(senderId);
      final receiverRef = db.collection('users').doc(receiverId);
      batch.update(senderRef, {
        'outgoingFriendRequests': FieldValue.arrayUnion([requestId]),
      });
      batch.update(receiverRef, {
        'incomingFriendRequests': FieldValue.arrayUnion([requestId]),
      });

      // commit the batch
      await batch.commit();

      logger.i("Friend request sent successfully.");
      return "Friend request sent successfully.";
    } catch (e) {
      logger.e("Error sending friend request", error: e);
      return "Error sending friend request: $e";
    }
  }

  // Accept a friend request
  Future<String> acceptFriendRequest(String requestId) async {
    try {
      final requestDoc =
          await db.collection('friend_requests').doc(requestId).get();
      if (!requestDoc.exists) {
        return "Friend request not found.";
      }

      final requestData = requestDoc.data()!;
      final senderId = requestData['senderId'];
      final receiverId = requestData['receiverId'];

      // start a batch
      final batch = db.batch();

      // add each other to friends list
      final senderRef = db.collection('users').doc(senderId);
      final receiverRef = db.collection('users').doc(receiverId);
      batch.update(senderRef, {
        'friends': FieldValue.arrayUnion([receiverId]),
        'outgoingFriendRequests': FieldValue.arrayRemove([requestId]),
      });
      batch.update(receiverRef, {
        'friends': FieldValue.arrayUnion([senderId]),
        'incomingFriendRequests': FieldValue.arrayRemove([requestId]),
      });

      // delete the friend request document
      final friendRequestRef = db.collection('friend_requests').doc(requestId);
      batch.delete(friendRequestRef);

      // commit the batch
      await batch.commit();

      logger.i("Friend request accepted successfully.");
      return "Friend request accepted successfully.";
    } catch (e) {
      logger.e("Error accepting friend request", error: e);
      return "Error accepting friend request: $e";
    }
  }

  // Cancel a friend request
  Future<String> cancelFriendRequest(String requestId) async {
    try {
      final requestDoc =
          await db.collection('friend_requests').doc(requestId).get();
      if (!requestDoc.exists) {
        return "Friend request not found.";
      }

      final requestData = requestDoc.data()!;
      final senderId = requestData['senderId'];
      final receiverId = requestData['receiverId'];

      // start a batch
      final batch = db.batch();

      // remove friend request references
      final senderRef = db.collection('users').doc(senderId);
      final receiverRef = db.collection('users').doc(receiverId);
      batch.update(senderRef, {
        'outgoingFriendRequests': FieldValue.arrayRemove([requestId]),
      });
      batch.update(receiverRef, {
        'incomingFriendRequests': FieldValue.arrayRemove([requestId]),
      });

      // delete the friend request document
      final friendRequestRef = db.collection('friend_requests').doc(requestId);
      batch.delete(friendRequestRef);

      // commit the batch
      await batch.commit();

      logger.i("Friend request canceled successfully.");
      return "Friend request canceled successfully.";
    } catch (e) {
      logger.e("Error canceling friend request", error: e);
      return "Error canceling friend request: $e";
    }
  }

  // Unfriend a user
  Future<String> unfriend(String userId1, String userId2) async {
    try {
      // start a batch
      final batch = db.batch();

      // remove each other from friends list
      final user1Ref = db.collection('users').doc(userId1);
      final user2Ref = db.collection('users').doc(userId2);
      batch.update(user1Ref, {
        'friends': FieldValue.arrayRemove([userId2]),
      });
      batch.update(user2Ref, {
        'friends': FieldValue.arrayRemove([userId1]),
      });

      // commit the batch
      await batch.commit();

      logger.i("Unfriended successfully.");
      return "Unfriended successfully.";
    } catch (e) {
      logger.e("Error unfriending user", error: e);
      return "Error unfriending user: $e";
    }
  }
}
