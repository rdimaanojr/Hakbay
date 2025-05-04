import 'package:flutter/material.dart';
import 'package:hakbay/commons/bottom_navbar.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class TravelPlanPage extends StatefulWidget{
  const TravelPlanPage({super.key});

  @override
  State<TravelPlanPage> createState() => _TravelPlanPageState();
}

class _TravelPlanPageState extends State<TravelPlanPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travel Plans"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Travel Plan Page"),
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
      bottomNavigationBar: BottomNavbar(currentIndex: 0),
    );
  }
}