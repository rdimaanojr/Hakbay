import 'package:flutter/material.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:hakbay/screens/init_interests_screen.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  late String fname;
  late String lname;
  late String username;
  late String email;
  late String password;
  bool showSignUpErrorMessage = false;
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  heading,
                  fNameField,
                  lNameField,
                  usernameField, 
                  emailField, 
                  passwordField, 
                  showSignUpErrorMessage ? signUpErrorMessage : Container(),
                  submitButton
                ],
              ),
            )),
      ),
    );
  }

  // Widgets for the sign-up form
  Widget get heading => const Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: Text(
          "Sign Up",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      );

  // Text fields for first name, last name, username, email, and password
  Widget get fNameField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("First Name"),
          ),
          onSaved: (value) => setState(() => fname = value!),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your first name";
            }
            return null;
          },
        ),
      );

  Widget get lNameField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Last Name"),
          ),
          onSaved: (value) => setState(() => lname = value!),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your last name";
            }
            return null;
          },
        ),
      );

  Widget get usernameField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Username"),
              hintText: "Enter a unique username"),
          onSaved: (value) => setState(() => username = value!),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your username";
            }
            return null;
          },
        ),
      );

  Widget get emailField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Email"),
              hintText: "Enter a valid email"),
          onSaved: (value) => setState(() => email = value!),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your email";
            }
            return null;
          },
        ),
      );

  Widget get passwordField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Password"),
              hintText: "Enter a valid password"),
          obscureText: true,
          onSaved: (value) => setState(() => password = value!),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your password";
            }
            return null;
          },
        ),
      );

  Widget get submitButton => ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          // Check if username is unique         
          final isTaken = await context.read<UserProvider>().isUsernameTaken(username);
          if (isTaken) {
            setState(() {
              showSignUpErrorMessage = true;
              errorMessage = "Username is already taken. Please choose another.";
            });
            return;
          }

          // Sign up the user
          String? message = await context.read<UserAuthProvider>().signUp(email, password);
          
          // Check if the sign-up was successful or if there was an error
          if (message.isNotEmpty) {
            setState(() {
              showSignUpErrorMessage = true;
              errorMessage = message; // Display the error message from the API
            });
            return;
          }

          // Get the user's UID
          final uid = context.read<UserAuthProvider>().getCurrentUserUID();

          // Create a new AppUser object
          final newUser = AppUser(
            uid: uid,
            fname: fname,
            lname: lname,
            username: username,
            email: email,
          );

          // Save the user in Firestore
          await context.read<UserProvider>().saveUser(uid!, newUser);

          // Navigate back if successful
          if (mounted) Navigator.popAndPushNamed(context, '/home');
        }
      },
      child: const Text("Sign Up")
    );

  Widget get signUpErrorMessage => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: Center(
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.red),),
    ),
  );

}