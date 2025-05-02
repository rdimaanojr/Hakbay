import 'dart:convert';

class AppUser {
  String? uid;
  String fname;
  String lname;
  String username;
  String email;

  AppUser({this.uid, required this.fname, required this.lname,
  required this.username, required this.email});

  // Factory constructor to instantiate object from json format
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      fname: json['fname'],
      lname: json['lname'],
      username: json['username'],
      email: json['email'],
    );
  }

  static List<AppUser> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<AppUser>((dynamic d) => AppUser.fromJson(d)).toList();
  }

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'fname': fname, 'lname': lname, 'username': username,
    'email': email};
  }

}