import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SimilarPeoplePage extends StatefulWidget {
  const SimilarPeoplePage({super.key});

  @override
  State<SimilarPeoplePage> createState() => _SimilarPeoplePageState();
}

class _SimilarPeoplePageState extends State<SimilarPeoplePage> {
  @override
  void initState() {
    super.initState();
    // Fetch similar users when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        context.read<UserProvider>().fetchSimilarUsers(userId);
      }
    });
  }

  @override
  void dispose() {
    context.read<UserProvider>().clearSimilarUsers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find Similar People")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.loadingSimilarUsers) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userProvider.similarUsersError != null) {
              return Center(
                child: Text(
                  'Error: ${userProvider.similarUsersError}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (userProvider.similarUsers.isEmpty) {
              return const Center(
                child: Text(
                  'No similar users found',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              itemCount: userProvider.similarUsers.length,
              itemBuilder: (context, index) {
                return _buildSimilarPersonTile(userProvider.similarUsers[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSimilarPersonTile(AppUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B223F),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 56,
              backgroundColor: Colors.amber,
              backgroundImage:
                  user.profilePic != null
                      ? MemoryImage(base64Decode(user.profilePic!))
                      : null,
              child:
                  user.profilePic == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Username
                  Text(
                    "${user.fname} ${user.lname}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  Text(
                    "@${user.username}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Interests
                  AutoScrollingTags(
                    tags: user.interests,
                    color: const Color(0xFF2D8CFF),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Travel Styles
                  AutoScrollingTags(
                    tags: user.travelStyles,
                    color: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AutoScrollingTags extends StatefulWidget {
  final List<String> tags;
  final Color color;

  const AutoScrollingTags({super.key, required this.tags, required this.color});

  @override
  State<AutoScrollingTags> createState() => _AutoScrollingTagsState();
}

class _AutoScrollingTagsState extends State<AutoScrollingTags> {
  late ScrollController _scrollController;
  bool _shouldScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForScroll();
    });
  }

  void _checkForScroll() {
    if (_scrollController.hasClients) {
      setState(() {
        _shouldScroll = _scrollController.position.maxScrollExtent > 0;
      });
      if (_shouldScroll) {
        _startScrolling();
      }
    }
  }

  void _startScrolling() async {
    while (_shouldScroll) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_shouldScroll) return;

      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(
          seconds: _scrollController.position.maxScrollExtent ~/ 50,
        ),
        curve: Curves.linear,
      );

      if (!mounted || !_shouldScroll) return;
      await Future.delayed(const Duration(seconds: 2));

      await _scrollController.animateTo(
        0,
        duration: Duration(
          seconds: _scrollController.position.maxScrollExtent ~/ 50,
        ),
        curve: Curves.linear,
      );
    }
  }

  @override
  void dispose() {
    _shouldScroll = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            widget.tags.map((tag) {
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
