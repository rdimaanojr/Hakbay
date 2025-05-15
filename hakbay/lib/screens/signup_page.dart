import 'package:flutter/material.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:hakbay/screens/init_interests_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/utils/logger.dart';

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
<<<<<<< HEAD
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
<<<<<<< HEAD
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
=======
    child: const Text("Sign Up"),
=======
    padding: EdgeInsets.only(bottom: 30),
    child: Text(
      "Sign Up",
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );

  // Text fields for first name, last name, username, email, and password
  Widget get fNameField => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextFormField(
      decoration: const InputDecoration(
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
        label: Text("Username"),
        hintText: "Enter a unique username",
      ),
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
        label: Text("Email"),
        hintText: "Enter a valid email",
      ),
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
        label: Text("Password"),
        hintText: "Enter a valid password",
      ),
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
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF1DB954),
      padding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      )
    ),
    child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 18)),
>>>>>>> c728cf8 (ui: frontend themes are implemented in travel plan and authentication pages)
    onPressed: () async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
>>>>>>> d376e6f (fix: bug in signing in)

<<<<<<< HEAD
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
=======
        // Check if username is unique
        final isTaken = await context.read<UserProvider>().isUsernameTaken(
          username,
        );
        logger.d("Is username taken: $isTaken");
        if (isTaken) {
          setState(() {
            showSignUpErrorMessage = true;
            errorMessage = "Username is already taken. Please choose another.";
          });
          return;
>>>>>>> a28a555 (fix: FIX signup logic)
        }
<<<<<<< HEAD
      },
      child: const Text("Sign Up")
    );
=======

        // Sign up the user
        String message = await context.read<UserAuthProvider>().signUp(
          email,
          password,
        );
        logger.d("Sign-up result: $message");

        // Check if the sign-up was successful
        if (message != "success") {
          setState(() {
            showSignUpErrorMessage = true;
            errorMessage = message; // Display the error message from the API
          });
          return;
        }

        // Get the user's UID
        final uid = context.read<UserAuthProvider>().getCurrentUserUID();
        logger.d("Retrieved UID: $uid");

        // Create a new AppUser object
        final newUser = AppUser(
          uid: uid,
          fname: fname,
          lname: lname,
          username: username,
          email: email,
        );

        // Save the user in Firestore
        logger.d("Saving user: ${newUser.toJson()}");
        await context.read<UserProvider>().saveUser(uid!, newUser);

        // Navigate forward if successful
        if (mounted) {
          logger.d("Navigating to /init-interests");
          context.go('/init-interests'); // Use GoRouter to navigate
        }
      }
    },
  );
>>>>>>> d376e6f (fix: bug in signing in)

  Widget get signUpErrorMessage => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: Center(
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.red),),
    ),
  );

}