import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:hakbay/commons/bottom_navbar.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  AppUser? user;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Flexible(
                  child: GestureDetector( // Button that will upload a picture from camera and display it in the form
                  onTap: () async {
                    final image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    );

                    setState(() {
                      imageFile = image == null ? null : File(image.path);
                    });
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: imageFile != null ? FileImage(imageFile!) : null,
                    child: imageFile == null // Circle will display an icon when no picture is uploaded
                      ? const Icon(Icons.photo_camera, size: 30, color: Colors.black)
                      : null,
                  ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "${user!.fname} ${user!.lname}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 5),
                Text(
                  "@${user!.username}",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   "Phone Number: ${user!.phone}",
                    //   style: const TextStyle(fontSize: 16, color: Colors.black87),
                    // ),
                    // const SizedBox(height: 10),
                    // Text(
                    //   "Email: ${user!.email}",
                    //   style: const TextStyle(fontSize: 16, color: Colors.black87),
                    // ),
                    // const SizedBox(height: 10),
                    // Text(
                    //   "Interests: ${user!.interests.join(', ')}",
                    //   style: const TextStyle(fontSize: 16, color: Colors.black87),
                    // ),
                    // const SizedBox(height: 10),
                    // Text(
                    //   "Travel Styles: ${user!.travelStyles.join(', ')}",
                    //   style: const TextStyle(fontSize: 16, color: Colors.black87),
                    // ),
                    const SizedBox(height: 20),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => EditProfilePage(),
                    //     ),
                    //     );
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blueAccent,
                    //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    //     shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   ),
                    //   child: const Text(
                    //     "Edit Profile",
                    //     style: TextStyle(fontSize: 16, color: Colors.white),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<UserAuthProvider>().signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
        ),
      ),),
      bottomNavigationBar: BottomNavbar(currentIndex: 2),
    );
  }
}
