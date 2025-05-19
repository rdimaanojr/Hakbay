import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hakbay/api/firebase_friend_api.dart';
import 'package:hakbay/firebase_options.dart';
import 'package:hakbay/utils/logger.dart';

void main() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i("Firebase initialized successfully.");
  } catch (e) {
    logger.e("Error initializing Firebase", error: e);
    return;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: TestApp());
  }
}

class TestApp extends StatefulWidget {
  const TestApp({super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  final friendAPI = FirebaseFriendAPI();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: runTestCode,
          child: const Text("Run Test Code"),
        ),
      ),
    );
  }

  void runTestCode() async {

    // Test data
    const user1Id = "testUser1";
    const user2Id = "testUser2";
    const user3Id = "testUser3";

    // Add test users (no security rules, so we can add directly)
    logger.d("Adding test users...");
    await FirebaseFriendAPI.db.collection('users').doc(user1Id).set({
      'uid': user1Id,
      'friends': [],
      'outgoingFriendRequests': [],
      'incomingFriendRequests': [],
    });
    await FirebaseFriendAPI.db.collection('users').doc(user2Id).set({
      'uid': user2Id,
      'friends': [],
      'outgoingFriendRequests': [],
      'incomingFriendRequests': [],
    });
    logger.i("Test users added.");

    // Test addFriendRequest
    logger.d("Testing addFriendRequest...");
    final addFriendResult = await friendAPI.addFriendRequest(user1Id, user2Id);
    logger.i("addFriendRequest result: $addFriendResult");

    // Test acceptFriendRequest
    logger.d("Testing acceptFriendRequest...");
    final friendRequests =
        await FirebaseFriendAPI.db.collection('friend_requests').get();
    if (friendRequests.docs.isNotEmpty) {
      final requestId = friendRequests.docs.first.id;
      final acceptFriendResult = await friendAPI.acceptFriendRequest(requestId);
      logger.i("acceptFriendRequest result: $acceptFriendResult");
    } else {
      logger.e("No friend requests found to accept.");
    }

    // Test unfriend
    logger.d("Testing unfriend...");
    final unfriendResult = await friendAPI.unfriend(user1Id, user2Id);
    logger.i("unfriend result: $unfriendResult");

    // // Clean up test users
    // logger.d("Cleaning up test users...");
    // await FirebaseFriendAPI.db.collection('users').doc(user1Id).delete();
    // await FirebaseFriendAPI.db.collection('users').doc(user2Id).delete();
    // logger.i("Test users cleaned up.");
  }
}
