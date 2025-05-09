import 'package:flutter/material.dart';
import 'package:hakbay/commons/bottom_navbar.dart';

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
          ],
        ),
      ),
    );
  }
}