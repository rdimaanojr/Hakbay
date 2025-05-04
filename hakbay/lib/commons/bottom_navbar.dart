import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, "/home");
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, "/people");
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, "/profile");
        }
      },
      indicatorColor: Colors.blue,
      selectedIndex: currentIndex,
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.group),
          label: 'Find Similar People',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
