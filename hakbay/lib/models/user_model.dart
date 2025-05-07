import 'dart:convert';

class AppUser {
  String? uid;
  String fname;
  String lname;
  String username;
  String email;
  String phone;
  List<String> interests;
  List<String> travelStyles;
  String? profilePic;
  bool isPrivate;

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
  final String timestamp;

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

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      status: json['status'],
      type: json['type'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
      'type': type,
      'timestamp': timestamp,
    };
  }
}
