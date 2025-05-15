import 'package:flutter/material.dart';
import 'package:hakbay/models/util_models.dart';
import 'package:provider/provider.dart';
import 'package:hakbay/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class InitTravelStylesScreen extends StatefulWidget {
  const InitTravelStylesScreen({super.key});

  @override
  State<InitTravelStylesScreen> createState() => _InitTravelStylesScreenState();
}

class _InitTravelStylesScreenState extends State<InitTravelStylesScreen> {
  final List<String> selectedTravelStyles = [];
  late String uid;
  late AppUser? user;

  @override
  void initState() {
    super.initState();
    uid = context.read<UserAuthProvider>().getCurrentUserUID() ?? '';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await context.read<UserProvider>().fetchUserData(uid);
      if (userData != null && userData.isNotEmpty) {
        setState(() {
          user = AppUser.fromJson(userData);
        });
      }
    } catch (e) {}
  }

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
                      TravelStyle.all.map((travelStyle) {
                        final isSelected = selectedTravelStyles.contains(
                          travelStyle,
                        );
                        return GestureDetector(
                          onTap: () => toggleTravelStyle(travelStyle),
                          child: Chip(
                            label: Text(
                              travelStyle,
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
                        .map((travelStyle) => Chip(label: Text(travelStyle)))
                        .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton(
                onPressed: () async {
                  if (user != null) {
                    await Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).updateUser(
                      uid,
                      user!.fname,
                      user!.lname,
                      user!.phone,
                      user!.interests,
                      selectedTravelStyles,
                      user!.isPrivate,
                    );

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/home",
                      (route) => false,
                    );
                  }
                },
                child: const Text("Continue"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GestureDetector(
                onTap: () {
                  // logic
<<<<<<< HEAD
<<<<<<< HEAD
=======
                  Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
>>>>>>> a800b17 (chore: ADD profile init screen routing)
=======
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/home",
                    (route) => false,
                  );
>>>>>>> 9dc5dae (chore: INTEGRATE interest and travel style to db)
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