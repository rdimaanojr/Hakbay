import 'dart:convert';

class AppUser {
  final String? uid;
  final String fname;
  final String lname;
  final String username;
  final String email;
  final String phone;
  final List<String> interests;
  final List<String> travelStyles;
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
    Object? profilePic = _undefined,
    bool? isPrivate,
  }) {
    return AppUser(
      uid: uid == _undefined ? null : uid as String?,
      fname: fname ?? '',
      lname: lname ?? '',
      username: username ?? '',
      email: email ?? '',
      phone: phone ?? '',
      interests: interests ?? [],
      travelStyles: travelStyles ?? [],
      profilePic: profilePic == _undefined ? null : profilePic as String?,
      isPrivate: isPrivate ?? false,
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
      'profilePic': profilePic,
      'isPrivate': isPrivate,
    };
  }
}

class FriendRequest {
  final String senderId;
  final String receiverId;
  final String type;
  final String status;
  final DateTime timestamp;

  static const String send = "send";
  static const String receive = "receive";
  static const String pending = "pending";
  static const String accepted = "accepted";
  static const String rejected = "rejected";

  FriendRequest({
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.type,
    required this.timestamp,
  });

  FriendRequest copyWith({
    String? senderId,
    String? receiverId,
    String? status,
    String? type,
    DateTime? timestamp,
  }) {
    return FriendRequest(
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      status: json['status'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
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
