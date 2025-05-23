import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:hakbay/screens/edit_profile_page.dart';
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
      source: await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Select Image Source"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(ImageSource.camera),
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () => context.pop(ImageSource.gallery),
              child: const Text("Gallery"),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ?? ImageSource.camera,
      imageQuality: 50,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (image != null) {
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      final encoded = base64Encode(bytes);
      setState(() {
        imageFile = file;
        base64Image = encoded;
        user = user!.copyWith(profilePic: encoded);
      });

      context.read<UserProvider>().updateUserProfilePic(uid, encoded).then((_) {
        logger.i("Profile picture updated successfully!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }).catchError((error) {
        logger.e("Error updating profile picture", error: error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update picture: ${error.toString()}')),
        );
      });
    }
  }

  Widget _buildProfileHeader() {
    final imageWidget = (base64Image != null && base64Image!.isNotEmpty)
        ? Image.memory(base64Decode(base64Image!), fit: BoxFit.cover)
        : const Icon(Icons.person, size: 50, color: Colors.white70);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
<<<<<<< HEAD
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "${user!.fname} ${user!.lname}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "@${user!.username}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 196, 196, 196),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Email: ${user!.email}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Interests: ${user!.interests.join(', ')}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Travel Styles: ${user!.travelStyles.join(', ')}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedUser = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(user: user),
                      ),
                    );

                    if (updatedUser != null) {
                      // Update your state with the new user data
                      setState(() {
                        user = updatedUser;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
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
=======
              ),
              child: ClipOval(
                child: imageWidget,
              ),
>>>>>>> 0b4ecf6 (style: improve ui)
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 49, 124, 52),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 20),
                color: Colors.white,
                onPressed: pickImage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "${user!.fname} ${user!.lname}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "@${user!.username}",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color.fromARGB(255, 102, 207, 120).withOpacity(0.1),
      child: ListTile(
        leading: Icon(icon, color: Color.fromARGB(255, 11, 137, 76)),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Interests",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user!.interests.map((interest) => Chip(
            label: Text(interest),
            backgroundColor: const Color.fromARGB(255, 22, 85, 55).withOpacity(0.5),
            labelStyle: const TextStyle(color: Color(0xFF101F1B)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildTravelStylesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Travel Styles",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user!.travelStyles.map((style) => Chip(
            label: Text(style),
            backgroundColor: const Color.fromARGB(255, 22, 85, 55).withOpacity(0.5),
            labelStyle: const TextStyle(color: Color(0xFF101F1B)),
          )).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: Color(0xFF101F1B),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF101F1B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final updatedUser = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(user: user),
                ),
              );
              if (updatedUser != null) {
                setState(() => user = updatedUser);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildInfoCard("Email", user!.email, Icons.email),
            _buildInfoCard("Phone", user!.phone, Icons.phone),
            const SizedBox(height: 16),
            _buildInterestsSection(),
            const SizedBox(height: 16),
            _buildTravelStylesSection(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Logout", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await context.read<UserAuthProvider>().signOut();
                    if (mounted) context.go('/');
                  }
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}