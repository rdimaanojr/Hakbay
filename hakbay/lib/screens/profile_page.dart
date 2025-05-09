import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/utils/logger.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  String? base64Image;
  File? imageFile;
  AppUser? user;
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = context.read<UserAuthProvider>().getCurrentUserUID() ?? '';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      await context.read<UserProvider>().fetchUserData(uid);
      final fetchedUser = context.read<UserProvider>().user;

      if (fetchedUser != null) {
        setState(() {
          user = fetchedUser;
          base64Image = user!.profilePic;
        });
      } else {
        logger.w("User data is null or empty.");
      }
    } catch (e) {
      logger.e("Error loading user data", error: e);
    }
  }

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(
      source:
          await showDialog<ImageSource>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("Select Image Source"),
                  actions: [
                    TextButton(
                      onPressed:
                          () => context.pop(ImageSource.camera),
                      child: const Text("Camera"),
                    ),
                    TextButton(
                      onPressed:
                          () => context.pop(ImageSource.gallery),
                      child: const Text("Gallery"),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
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
      setState(() {
        imageFile = file;
        base64Image = encoded;
        user = user!.copyWith(profilePic: encoded);

        context
            .read<UserProvider>()
            .updateUserProfilePic(uid, encoded)
            .then((_) {
              print("Profile picture updated successfully!");
            })
            .catchError((error) {
              print("Error updating profile picture: $error");
            });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final imageWidget =
        (base64Image != null && base64Image!.isNotEmpty)
            ? Image.memory(base64Decode(base64Image!), fit: BoxFit.cover)
            : const Icon(Icons.person, size: 50);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: ClipOval(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: imageWidget,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "${user!.fname} ${user!.lname}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "@${user!.username}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Phone Number: ${user!.phone}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Email: ${user!.email}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Interests: ${user!.interests.join(', ')}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Travel Styles: ${user!.travelStyles.join(', ')}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await context.push<AppUser?>(
                      '/edit-profile',
                      extra: user,
                    );

                    if (result != null) {
                      setState(() {
                        user = result;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
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
<<<<<<< HEAD
<<<<<<< HEAD
                  child: ListTile(
                    onTap: () async {
                      try {
                        await context.read<UserAuthProvider>().signOut();
                        if (mounted) {
                          Navigator.popAndPushNamed(context, '/');
                        }
                      } catch (e) {
                        print("Error during logout: $e");
                      } finally {
                        Navigator.pop(context); // Close the loading dialog
                      }
=======

                  child: ListTile(
                    // Logout button
                    onTap: () async {
                      await context.read<UserAuthProvider>().signOut();
                      if (mounted) {
                        context.go('/');
                      }
                      ;
>>>>>>> a3ce398 (refactor: REFACTOR code base)
                    },
                    title: const Center(
                      child: Text(
                        "Logout",
                        style: TextStyle(color: Colors.red),
                      ),
<<<<<<< HEAD
=======
                  child: ListTile( // Logout button
                  onTap: () async {
                    await context.read<UserAuthProvider>().signOut();
                    if (mounted) {
                      Navigator.popAndPushNamed(context, '/');
                    };
                  },
                  title: const Center(
                    child: Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
<<<<<<< HEAD
>>>>>>> 96555be (fix: Rerouting with logout and pages)
=======


>>>>>>> d376e6f (fix: bug in signing in)
=======
>>>>>>> a3ce398 (refactor: REFACTOR code base)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
