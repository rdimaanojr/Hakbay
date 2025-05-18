import 'package:flutter/material.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  String? username;
  String? password;
  bool showSignInErrorMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 100, horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                heading,
                usernameField,
                passwordField,
                showSignInErrorMessage ? signInErrorMessage : Container(),
                submitButton,
                signUpButton,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widgets for the sign-in form
  Widget get heading => const Padding(
    padding: EdgeInsets.only(bottom: 30),
    child: Text(
      "Sign In",
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );

  // Text fields for username and password
  Widget get usernameField => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        label: Text("Username"),
      ),
      onSaved: (value) => setState(() => username = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your username";
        }
        return null;
      },
    ),
  );

  Widget get passwordField => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        label: Text("Password"),
      ),
      obscureText: true,
      onSaved: (value) => setState(() => password = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your password";
        }
        return null;
      },
    ),
  );

  Widget get signInErrorMessage => const Padding(
    padding: EdgeInsets.only(bottom: 30),
    child: Text(
      "Invalid username or password",
      style: TextStyle(color: Colors.red),
    ),
  );

  Widget get submitButton => ElevatedButton(
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.all(16),
    ),
    onPressed: () async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        try {
          // Check if username already signed up
          final email = await context.read<UserProvider>().getEmailByUsername(
            username!,
          );

          if (email.isEmpty) {
            // Username does not exist
            setState(() {
              showSignInErrorMessage = true;
            });
            return;
          }

          // Sign in
          String message = await context.read<UserAuthProvider>().signIn(
            email,
            password!,
          );

          // Check if the sign-in was successful or if there was an error
          if (message.isNotEmpty) {
            setState(() {
              showSignInErrorMessage = true;
            });
            return;
          }

          // Navigate to the next page if sign-in is successful
          if (mounted) {
            context.go('/home');
          }
        } catch (e) {
          // Handle unexpected errors
          setState(() {
            showSignInErrorMessage = true;
          });
        }
      }
    },
    child: const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 18),),
  );

  Widget get signUpButton => Padding(
    padding: const EdgeInsets.all(30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("No account yet?", style: TextStyle(color: Colors.white),),
        TextButton(
          onPressed: () {
            context.push('/signup');
          },
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF1DB954),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          child: const Text("Sign Up"),
        ),
      ],
    ),
  );
}
