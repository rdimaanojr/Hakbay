import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:hakbay/commons/bottom_navbar.dart';
import 'package:hakbay/screens/edit_profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  
  String? base64Image;
  AppUser? user;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Fetch user data from the database
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from the database
  Future<void> _loadUserData() async {
    try {
      final userData = await context.read<UserProvider>().fetchUserData(uid);
      if (userData != null && userData.isNotEmpty) {
        setState(() {
          user = AppUser.fromJson(userData);
          //base64Image = user?.profilePic;
        });
      } else {
        print("User data is null or empty.");
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  // Pick an image from the camera or gallery
  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(
      source: await showDialog<ImageSource>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Select Image Source"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                  child: const Text("Camera"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  child: const Text("Gallery"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ) ??
          ImageSource.camera,
    );

    if (image != null) {
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      final encoded = base64Encode(bytes);

      // // Save the profile picture to the database
      // await context.read<UserProvider>().fireBaseService.updateUser(uid, {
      //   'profilePic': encoded,
      // } as String);

      setState(() {
        base64Image = encoded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold( // Loading state
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Display the profile picture or a default icon if not available
    final imageWidget = base64Image != null
        ? Image.memory(
            base64Decode(base64Image!),
            fit: BoxFit.cover,
          )
        : const Icon(Icons.person, size: 50);


    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
                children: [
                GestureDetector(
                  onTap: pickImage, // Open image picker on tap
                  child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: ClipOval(
                    child: SizedBox(width: 100, height: 100, child: imageWidget),
                  ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(  
                  child: Column(
                  children: [  
                    Text( // Display user's full name
                    "${user!.fname} ${user!.lname}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 5),
                    Text( // Display user's username
                    "@${user!.username}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text( // Display user's phone number
                    "Phone Number: ${user!.phone}",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text( // Display user's email address
                    "Email: ${user!.email}",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text( // Display user's interests
                    "Interests: ${user!.interests.join(', ')}",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text( // Display user's travel styles
                    "Travel Styles: ${user!.travelStyles.join(', ')}",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  ],
                ),
                ElevatedButton( // Edit Profile button
                  onPressed: () async{
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: user),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        user = result; // Update the user data after editing
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  ),
                  child: const Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ListTile( // Logout button
                  onTap: () async {
                    await context.read<UserAuthProvider>().signOut();
                    Navigator.pushNamedAndRemoveUntil(
                    context, "/", (route) => false);
                  },
                  title: const Center(
                    child: Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ),
                ),
              ],
            ),
        ),
      ),),
      bottomNavigationBar: BottomNavbar(currentIndex: 2), // Bottom navigation bar
    );
  }
}
