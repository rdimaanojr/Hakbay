import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hakbay/api/firebase_user_api.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/utils/logger.dart';

class UserProvider with ChangeNotifier {
  final FirebaseUserAPI userAPI = FirebaseUserAPI();
  AppUser? user;
  UserState _status = UserState.initial();

  AppUser? get userData => user;
  UserState get status => _status;

  late Stream<QuerySnapshot> _sharedUserStream;
  Stream<QuerySnapshot> get getSharedUsers => _sharedUserStream;

  void fetchSharedUsers(List<String> uids) {
    _sharedUserStream = userAPI.fetchSharedUsers(uids);
  }

  // Get user data from Firestore
  Future<void> fetchUserData(String uid) async {
    _status = UserState.loading();
    notifyListeners();

    try {
      final userData = await userAPI.getUser(uid);
      if (userData != null) {
        user = AppUser.fromJson(userData);
        _status = UserState.success();
        logger.d('User data fetched successfully: ${user?.toJson()}');
      } else {
        _status = UserState.error('User not found');
        logger.e('User Not Found', error: 'No user data found for uid: $uid');
      }
    } catch (e) {
      _status = UserState.error('Error fetching user data');
      logger.e('Error fetching user data', error: e);
    }

    notifyListeners();
  }

  // Streams for friend system
  Stream<List<String>> getFriendsStream() {
    if (user == null) return Stream.value([]);
    return userAPI.getFriendsStream(user!.uid!);
  }

  Stream<List<String>> getIncomingFriendRequestsStream() {
    if (user == null) return Stream.value([]);
    return userAPI.getIncomingFriendRequestsStream(user!.uid!);
  }

  Stream<List<String>> getOutgoingFriendRequestsStream() {
    if (user == null) return Stream.value([]);
    return userAPI.getOutgoingFriendRequestsStream(user!.uid!);
  }

  Stream<List<Map<String, dynamic>>> getSimilarUsersStream() {
    if (user == null) return Stream.value([]);
    return userAPI.getSimilarUsersStream(user!.uid!);
  }

  Future<AppUser?> getUserDataById(String uid) async {
    try {
      final userData = await userAPI.getUser(uid);
      if (userData != null) {
        return AppUser.fromJson(userData);
      }
      return null;
    } catch (e) {
      logger.e('Error getting user data by ID', error: e);
      return null;
    }
  }

  // Save a new user and store it in Firestore
  Future<void> saveUser(String uid, AppUser user) async {
    String message = await userAPI.saveUser(uid, user.toJson());
    logger.d(message);
    notifyListeners();
  }

  // Check if a username is already taken
  Future<bool> isUsernameTaken(String username) async {
    return await userAPI.isUsernameTaken(username);
  }

  // Get email by username
  Future<String> getEmailByUsername(String username) async {
    return await userAPI.getEmailByUsername(username);
  }

  // Update user data in Firestore
  Future<void> updateUser({
    required String uid,
    String? fname,
    String? lname,
    String? phone,
    List<String>? interests,
    List<String>? travelStyles,
    String? profilePic,
    bool? isPrivate,
  }) async {
    await userAPI.updateUser(
      uid: uid,
      fname: fname,
      lname: lname,
      phone: phone,
      interests: interests,
      travelStyles: travelStyles,
      profilePic: profilePic,
      isPrivate: isPrivate,
    );
    notifyListeners();
  }

  Future<void> updateUserProfilePic(String uid, String profilePic) async {
    await userAPI.updateUserProfilePic(uid, profilePic);
    notifyListeners();
  }

  // Friend System Methods
  Future<String> sendFriendRequest(String currentUserId, String receiverId) async {
    final result = await userAPI.sendFriendRequest(currentUserId, receiverId);
    await fetchUserData(currentUserId); // Refresh user data to get updated request lists
    notifyListeners();
    return result;
  }

  Future<String> acceptFriendRequest(String currentUserId, String requesterId) async {
    final result = await userAPI.acceptFriendRequest(currentUserId, requesterId);
    await fetchUserData(currentUserId); // Refresh user data to get updated friend list
    notifyListeners();
    return result;
  }

  Future<String> rejectFriendRequest(String currentUserId, String senderId) async {
    final result = await userAPI.rejectFriendRequest(currentUserId, senderId);
    await fetchUserData(currentUserId); // Refresh user data to get updated request lists
    notifyListeners();
    return result;
  }

  Future<String> cancelFriendRequest(String currentUserId, String receiverId) async {
    final result = await userAPI.cancelFriendRequest(currentUserId, receiverId);
    await fetchUserData(currentUserId); // Refresh user data to get updated request lists
    notifyListeners();
    return result;
  }

  Future<String> unfriend(String currentUserId, String friendId) async {
    final result = await userAPI.unfriend(currentUserId, friendId);
    await fetchUserData(currentUserId); // Refresh user data to get updated friend list
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> getFriendStatus(String currentUserId, String otherUserId) async {
    return await userAPI.getFriendStatus(currentUserId, otherUserId);
  }
}
