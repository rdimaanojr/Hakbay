import 'package:flutter/material.dart';
import 'package:hakbay/models/util_models.dart';

class InitInterestsScreen extends StatefulWidget {
  const InitInterestsScreen({super.key});

  @override
  State<InitInterestsScreen> createState() => _InitInterestsScreenState();
}

class _InitInterestsScreenState extends State<InitInterestsScreen> {
  final List<String> selectedInterests = [];

  void toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
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
                  "Select Interests",
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
                      Interest.all.map((interest) {
                        final isSelected = selectedInterests.contains(interest);
                        return GestureDetector(
                          onTap: () => toggleInterest(interest),
                          child: Chip(
                            label: Text(
                              interest,
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
                  selectedInterests.isNotEmpty
                      ? const Text(
                        "Your interests:",
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
                    selectedInterests
                        .map((interest) => Chip(label: Text(interest)))
                        .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GestureDetector(
                onTap: () {
                  // logic
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
