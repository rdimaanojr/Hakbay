import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar( // Bottom navigation bar
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            context.go('/home'); // Navigate to the Home page
            break;
          case 1:
            context.go('/people'); // Navigate to the Find Similar People page
            break;
          case 2:
            context.go('/profile'); // Navigate to the Profile page
            break;
        }
      },
      selectedIndex: currentIndex,
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.flight),
          label: 'Travels',
        ),
        NavigationDestination(
          icon: Icon(Icons.search),
          label: 'Find',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
