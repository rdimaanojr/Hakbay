import 'package:flutter/material.dart';
import 'package:hakbay/api/firebase_friend_api.dart';

class FriendProvider with ChangeNotifier {
  final FirebaseFriendAPI _friendAPI = FirebaseFriendAPI();

  // Send a friend request
  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    await _friendAPI.addFriendRequest(senderId, receiverId);
    notifyListeners();
  }

  // Accept a friend request
  Future<void> acceptFriendRequest(String requestId) async {
    await _friendAPI.acceptFriendRequest(requestId);
    notifyListeners();
  }

  // Cancel a friend request
  Future<void> cancelFriendRequest(String requestId) async {
    await _friendAPI.cancelFriendRequest(requestId);
    notifyListeners();
  }

  // Unfriend a user
  Future<void> unfriend(String userId1, String userId2) async {
    await _friendAPI.unfriend(userId1, userId2);
    notifyListeners();
  }
}