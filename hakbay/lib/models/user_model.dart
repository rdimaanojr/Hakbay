import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String? uid;
  final String fname;
  final String lname;
  final String username;
  final String email;
  final String phone;
  final List<String> interests;
  final List<String> travelStyles;
  final List<String> travelPlans;
  final List<String> friends;
  final List<String> outgoingFriendRequests;
  final List<String> incomingFriendRequests;
  final String? profilePic;
  final bool isPrivate;

  AppUser({
    this.uid,
    required this.fname,
    required this.lname,
    required this.username,
    required this.email,
    this.phone = '',
    this.interests = const [],
    this.travelStyles = const [],
    this.travelPlans = const [],
    this.friends = const [],
    this.outgoingFriendRequests = const [],
    this.incomingFriendRequests = const [],
    this.profilePic,
    this.isPrivate = false,
  });

  static const _undefined = Object();

  AppUser copyWith({
    Object? uid = _undefined,
    String? fname,
    String? lname,
    String? username,
    String? email,
    String? phone,
    List<String>? interests,
    List<String>? travelStyles,
    List<String>? travelPlans,
    List<String>? friends,
    List<String>? outgoingFriendRequests,
    List<String>? incomingFriendRequests,
    Object? profilePic = _undefined,
    bool? isPrivate,
  }) {
    return AppUser(
      uid: uid == _undefined ? this.uid : uid as String?,
      fname: fname ?? this.fname,
      lname: lname ?? this.lname,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      interests: interests ?? this.interests,
      travelStyles: travelStyles ?? this.travelStyles,
      travelPlans: travelPlans ?? this.travelPlans,
      friends: friends ?? this.friends,
      outgoingFriendRequests: outgoingFriendRequests ?? this.outgoingFriendRequests,
      incomingFriendRequests: incomingFriendRequests ?? this.incomingFriendRequests,
      profilePic: profilePic == _undefined ? this.profilePic : profilePic as String?,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  // Factory constructor to instantiate object from json format
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      fname: json['fname'],
      lname: json['lname'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      travelStyles: List<String>.from(json['travelStyles'] ?? []),
      travelPlans: List<String>.from(json['travelPlans'] ?? []),
      friends: List<String>.from(json['friends'] ?? []),
      outgoingFriendRequests: List<String>.from(json['outgoingFriendRequests'] ?? []),
      incomingFriendRequests: List<String>.from(json['incomingFriendRequests'] ?? []),
      profilePic: json['profilePic'],
      isPrivate: json['isPrivate'] ?? false,
    );
  }

  static List<AppUser> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<AppUser>((dynamic d) => AppUser.fromJson(d)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fname': fname,
      'lname': lname,
      'username': username,
      'email': email,
      'phone': phone,
      'interests': interests,
      'travelStyles': travelStyles,
      'travelPlans': travelPlans,
      'friends': friends,
      'outgoingFriendRequests': outgoingFriendRequests,
      'incomingFriendRequests': incomingFriendRequests,
      'profilePic': profilePic,
      'isPrivate': isPrivate,
    };
  }
}

class UserState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const UserState._({
    required this.isLoading,
    required this.isSuccess,
    this.error,
  });

  factory UserState.initial() =>
      const UserState._(isLoading: false, isSuccess: false);
  factory UserState.loading() =>
      const UserState._(isLoading: true, isSuccess: false);
  factory UserState.success() =>
      const UserState._(isLoading: false, isSuccess: true);
  factory UserState.error(String error) =>
      UserState._(isLoading: false, isSuccess: false, error: error);
}