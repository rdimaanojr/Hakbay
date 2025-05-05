import 'package:flutter/material.dart';
import 'package:hakbay/models/util_models.dart';
import 'package:hakbay/screens/travel_plan_page.dart';

class InitTravelStylesScreen extends StatefulWidget {
  const InitTravelStylesScreen({super.key});

  @override
  State<InitTravelStylesScreen> createState() => _InitTravelStylesScreenState();
}

class _InitTravelStylesScreenState extends State<InitTravelStylesScreen> {
  final List<String> selectedTravelStyles = [];

  void toggleTravelStyle(String travelStyle) {
    setState(() {
      if (selectedTravelStyles.contains(travelStyle)) {
        selectedTravelStyles.remove(travelStyle);
      } else {
        selectedTravelStyles.add(travelStyle);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 50, bottom: 50),
              child: Center(
                child: Text(
                  "Select TravelStyles",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      TravelStyle.all.map((TravelStyle) {
                        final isSelected = selectedTravelStyles.contains(TravelStyle);
                        return GestureDetector(
                          onTap: () => toggleTravelStyle(TravelStyle),
                          child: Chip(
                            label: Text(
                              TravelStyle,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor:
                                isSelected ? Colors.blue : Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 30,
              alignment: Alignment.center,
              child:
                  selectedTravelStyles.isNotEmpty
                      ? const Text( 
                        "Your Travel Styles:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            Container(
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    selectedTravelStyles
                        .map((TravelStyle) => Chip(label: Text(TravelStyle)))
                        .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const TravelPlanPage(),
                  ));
                },
                child: const Text(
                  "Skip for Now",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
