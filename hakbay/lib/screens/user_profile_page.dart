import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/utils/logger.dart';

class UserProfilePage extends StatefulWidget {
  final String uid;
  
  const UserProfilePage({super.key, required this.uid});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  AppUser? user;
  bool isLoading = true;
  String? error;
  String? currentUserId;
  bool isFriend = false;
  bool hasOutgoingRequest = false;
  bool hasIncomingRequest = false;

  @override
  void initState() {
    super.initState();
    currentUserId = context.read<UserAuthProvider>().getCurrentUserUID();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // First fetch the current user's data to get their request lists
      if (currentUserId != null) {
        await context.read<UserProvider>().fetchUserData(currentUserId!);
      }

      // Then fetch the profile user's data
      await context.read<UserProvider>().fetchUserData(widget.uid);
      final fetchedUser = context.read<UserProvider>().user;

      if (fetchedUser != null) {
        setState(() {
          user = fetchedUser;
        });

        if (currentUserId != null) {
          // Get the latest friend status from the current user's perspective
          final friendStatus = await context.read<UserProvider>().getFriendStatus(currentUserId!, widget.uid);
          if (mounted) {
            setState(() {
              isFriend = friendStatus['areFriends'];
              hasOutgoingRequest = friendStatus['hasOutgoingRequest'];
              hasIncomingRequest = friendStatus['hasIncomingRequest'];
            });
          }
        }
      } else {
        setState(() {
          error = "User not found";
        });
      }
    } catch (e) {
      setState(() {
        error = "Error loading user data: $e";
      });
      logger.e("Error loading user data", error: e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildFriendButton() {
    if (currentUserId == widget.uid) {
      return const SizedBox.shrink();
    }

    if (isFriend) {
      return ElevatedButton(
        onPressed: () async {
          try {
            await context.read<UserProvider>().unfriend(currentUserId!, widget.uid);
            await _loadUserData();
          } catch (e) {
            logger.e("Error unfriending user", error: e);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(200, 45),
        ),
        child: const Text("Unfriend", style: TextStyle(color: Colors.white)),
      );
    }

    if (hasOutgoingRequest) {
      return ElevatedButton(
        onPressed: () async {
          try {
            await context.read<UserProvider>().cancelFriendRequest(currentUserId!, widget.uid);
            await _loadUserData();
          } catch (e) {
            logger.e("Error canceling friend request", error: e);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          minimumSize: const Size(200, 45),
        ),
        child: const Text("Cancel Request", style: TextStyle(color: Colors.white)),
      );
    }

    if (hasIncomingRequest) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<UserProvider>().acceptFriendRequest(currentUserId!, widget.uid);
                await _loadUserData();
              } catch (e) {
                logger.e("Error accepting friend request", error: e);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(100, 45),
            ),
            child: const Text("Accept", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<UserProvider>().rejectFriendRequest(currentUserId!, widget.uid);
                await _loadUserData();
              } catch (e) {
                logger.e("Error rejecting friend request", error: e);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(100, 45),
            ),
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }

    return ElevatedButton(
      onPressed: () async {
        try {
          await context.read<UserProvider>().sendFriendRequest(currentUserId!, widget.uid);
          await _loadUserData();
        } catch (e) {
          logger.e("Error sending friend request", error: e);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D8CFF),
        minimumSize: const Size(200, 45),
      ),
      child: const Text("Add Friend", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildProfileContent() {
    if (user == null) return const SizedBox.shrink();

    final imageWidget = (user!.profilePic != null && user!.profilePic!.isNotEmpty)
        ? Image.memory(base64Decode(user!.profilePic!), fit: BoxFit.cover)
        : const Icon(Icons.person, size: 50);

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
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
          const SizedBox(height: 20),
          Text(
            "${user!.fname} ${user!.lname}",
            style: const TextStyle(
              fontSize: 24,
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
          const SizedBox(height: 30),
          _buildFriendButton(),
          const SizedBox(height: 40),
          if (!user!.isPrivate || isFriend) ...[
            if (user!.interests.isNotEmpty) ...[
              const Text(
                "Interests",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: user!.interests.map((interest) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D8CFF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    interest,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 30),
            ],
            if (user!.travelStyles.isNotEmpty) ...[
              const Text(
                "Travel Styles",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: user!.travelStyles.map((style) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    style,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 30),
            ],
            if (user!.travelPlans.isNotEmpty) ...[
              const Text(
                "Shared with Me",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              // TODO: Implement travel plans list
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101F1B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101F1B),
        title: const Text("Profile"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildProfileContent(),
                ),
    );
  }
} 