import 'package:firebase_auth/firebase_auth.dart';

// API for our User Authentication
class FirebaseAuthAPI {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<User?> getUserStream() {
    return auth.authStateChanges();
  }

  // Get the UID
  String? getCurrentUserUID() {
    return auth.currentUser?.uid;
  }

  // Sign In with Email and Password
  Future<String> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return "";
    } on FirebaseAuthException {
      return "Invalid Credentials!";
    }
  }

  // Sign up using email and password 
  Future<String> signUp(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return "Invalid Email Address";
        case 'email-already-in-use':
          return "The email address is already in use.";
        case 'password-does-not-meet-requirements':
          return "Password must contain at least 6 characters";
        default:
          return "Password must contain at least 6 characters";
      }
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await auth.signOut();
  }

}