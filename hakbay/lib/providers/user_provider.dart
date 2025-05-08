import 'package:flutter/material.dart';
import 'package:hakbay/api/firebase_user_api.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/utils/logger.dart';

// Our provider class
class UserProvider with ChangeNotifier {
  late FirebaseUserAPI userAPI;

  AppUser? _user;
  UserState _status = UserState.initial();

  AppUser? get user => _user;
  UserState get status => _status;

  // Get user data from Firestore
  Future<void> fetchUserData(String uid) async {
    _status = UserState.loading();
    notifyListeners();

    final data = await userAPI.getUser(uid);

    if (data != null) {
      data['uid'] = uid;
      _user = AppUser.fromJson(data);
      _status = UserState.success();
      logger.d('User data fetched successfully: ${_user?.toJson()}');
    } else {
      _status = UserState.error('User not found');
      logger.e('User Not Found', error: 'No user data found for uid: $uid');
    }

    notifyListeners();
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
}
