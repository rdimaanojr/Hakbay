import 'package:firebase_auth/firebase_auth.dart';

// API for our User Authentication
class FirebaseAuthAPI {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<User?> getUserStream() {
    return auth.authStateChanges();
  }

  Future<User?> getCurrentUser() async {
    return auth.currentUser;
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
      return "success"; // Return "success" on successful sign-up
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return "Invalid Email Address";
        case 'email-already-in-use':
          return "The email address is already in use.";
        case 'weak-password':
          return "Password must contain at least 6 characters";
        default:
          return e.message ?? "An unknown error occurred.";
      }
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await auth.signOut();
  }

}