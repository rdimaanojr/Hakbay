import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/utils/logger.dart';

class SimilarPeoplePage extends StatefulWidget {
  const SimilarPeoplePage({super.key});

  @override
  State<SimilarPeoplePage> createState() => _SimilarPeoplePageState();
}

class _SimilarPeoplePageState extends State<SimilarPeoplePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? currentUserId;
  Stream<List<String>>? _friendsStream;
  Stream<List<String>>? _requestsStream;
  Stream<List<Map<String, dynamic>>>? _similarUsersStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    currentUserId = context.read<UserAuthProvider>().getCurrentUserUID();

    // fetch user data when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (currentUserId == null) {
        logger.w('No current user ID found in SimilarPeoplePage');
        return;
      }

      final userProvider = context.read<UserProvider>();
      try {
        await userProvider.fetchUserData(currentUserId!);
        if (mounted) {
          setState(() {
            _setupStreams();
          });
        }
      } catch (e) {
        logger.e('Error fetching user data in SimilarPeoplePage', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading user data: ${e.toString()}')),
          );
        }
      }
    });
  }

  void _setupStreams() {
    if (currentUserId == null) {
      logger.w('Cannot setup streams: currentUserId is null');
      return;
    }

    try {
      final userProvider = context.read<UserProvider>();
      _friendsStream = userProvider.getFriendsStream();
      _requestsStream = userProvider.getIncomingFriendRequestsStream();
      _similarUsersStream = userProvider.getSimilarUsersStream();
      logger.d('Streams setup completed for user: $currentUserId');
    } catch (e) {
      logger.e('Error setting up streams', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting up streams: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildSimilarPersonTile(String uid) {
    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<AppUser?>(
      future: context.read<UserProvider>().getUserDataById(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final user = snapshot.data;
        if (user == null) return const SizedBox.shrink();

        return FutureBuilder<Map<String, dynamic>>(
          future: context.read<UserProvider>().getFriendStatus(
            currentUserId!,
            user.uid!,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }

            final friendStatus =
                snapshot.data ??
                {
                  'areFriends': false,
                  'hasOutgoingRequest': false,
                  'hasIncomingRequest': false,
                };

            return GestureDetector(
              onTap: () => context.push('/user/${user.uid}'),
              child: Padding(
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
                      // Friend Request Buttons
                      if (!friendStatus['areFriends'] &&
                          !friendStatus['hasOutgoingRequest'] &&
                          !friendStatus['hasIncomingRequest'])
                        IconButton(
                          icon: const Icon(
                            Icons.person_add,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            try {
                              await context
                                  .read<UserProvider>()
                                  .sendFriendRequest(currentUserId!, user.uid!);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                        )
                      else if (friendStatus['hasOutgoingRequest'])
                        IconButton(
                          icon: const Icon(
                            Icons.person_remove,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            try {
                              await context
                                  .read<UserProvider>()
                                  .cancelFriendRequest(
                                    currentUserId!,
                                    user.uid!,
                                  );
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                        )
                      else if (friendStatus['hasIncomingRequest'])
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () async {
                                try {
                                  await context
                                      .read<UserProvider>()
                                      .acceptFriendRequest(
                                        currentUserId!,
                                        user.uid!,
                                      );
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                try {
                                  await context
                                      .read<UserProvider>()
                                      .rejectFriendRequest(
                                        currentUserId!,
                                        user.uid!,
                                      );
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFriendTile(String uid) {
    return FutureBuilder<AppUser?>(
      future: context.read<UserProvider>().getUserDataById(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final user = snapshot.data;
        if (user == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => context.push('/user/${user.uid}'),
          child: Padding(
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
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        user.profilePic != null
                            ? MemoryImage(base64Decode(user.profilePic!))
                            : null,
                    child:
                        user.profilePic == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user.fname} ${user.lname}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "@${user.username}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 196, 196, 196),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Unfriend Button
                  IconButton(
                    icon: const Icon(Icons.person_remove, color: Colors.red),
                    onPressed: () async {
                      try {
                        await context.read<UserProvider>().unfriend(
                          currentUserId!,
                          user.uid!,
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestTile(String uid) {
    return FutureBuilder<AppUser?>(
      future: context.read<UserProvider>().getUserDataById(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final user = snapshot.data;
        if (user == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => context.push('/user/${user.uid}'),
          child: Padding(
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
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        user.profilePic != null
                            ? MemoryImage(base64Decode(user.profilePic!))
                            : null,
                    child:
                        user.profilePic == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user.fname} ${user.lname}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "@${user.username}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 196, 196, 196),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      try {
                        await context.read<UserProvider>().acceptFriendRequest(
                          currentUserId!,
                          user.uid!,
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      try {
                        await context.read<UserProvider>().rejectFriendRequest(
                          currentUserId!,
                          user.uid!,
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find People"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Similar People"),
            Tab(text: "Friends"),
            Tab(text: "Requests"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Similar People Tab
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _similarUsersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                final similarUsers = snapshot.data ?? [];
                if (similarUsers.isEmpty) {
                  return const Center(
                    child: Text(
                      "No similar people found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: similarUsers.length,
                  itemBuilder: (context, index) {
                    final userData = similarUsers[index];
                    final user = AppUser.fromJson(userData);
                    return _buildSimilarPersonTile(user.uid!);
                  },
                );
              },
            ),
            // Friends Tab
            StreamBuilder<List<String>>(
              stream: _friendsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                final friendIds = snapshot.data ?? [];
                if (friendIds.isEmpty) {
                  return const Center(
                    child: Text(
                      "No friends yet",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: friendIds.length,
                  itemBuilder:
                      (context, index) => _buildFriendTile(friendIds[index]),
                );
              },
            ),
            // Requests Tab
            StreamBuilder<List<String>>(
              stream: _requestsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                final requestIds = snapshot.data ?? [];
                if (requestIds.isEmpty) {
                  return const Center(
                    child: Text(
                      "No friend requests",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: requestIds.length,
                  itemBuilder:
                      (context, index) => _buildRequestTile(requestIds[index]),
                );
              },
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
