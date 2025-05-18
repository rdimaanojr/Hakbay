import 'package:flutter/material.dart';
import 'package:hakbay/commons/constants.dart';
import 'package:provider/provider.dart';
import 'package:hakbay/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/utils/logger.dart';

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
      await context.read<UserProvider>().fetchUserData(uid);
      final fetchedUser = context.read<UserProvider>().user;

      if (fetchedUser != null) {
        setState(() {
          user = fetchedUser;
        });
      } else {
        logger.w("User data is null or empty.");
      }
    } catch (e) {
      logger.e("Error loading user data", error: e);
    }
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
                  "Select Travel Styles",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      TravelStyles.all.map((travelStyle) {
                        final isSelected = selectedTravelStyles.contains(
                          travelStyle,
                        );
                        return GestureDetector(
                          onTap: () => toggleTravelStyle(travelStyle),
                          child: Chip(
                            label: Text(
                              travelStyle,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: isSelected
                                ? BorderSide(color: Theme.of(context).primaryColor, width: 1)
                                : BorderSide(color: Colors.transparent),
                            ),
                          )
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
                          color: Colors.white
                        ),
                      )
                      : null,
            ),
            Container(
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).cardColor),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).cardColor,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                  selectedTravelStyles
                    .map((travelStyle) => Chip(
                      label: Text(
                        travelStyle,
                        style: TextStyle(color: Colors.white),  
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    )).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: () async {
                  if (user != null) {
                    await Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).updateUser(
                      uid: uid,
                      fname: user!.fname,
                      lname: user!.lname,
                      phone: user!.phone,
                      interests: user!.interests,
                      travelStyles: selectedTravelStyles,
                      isPrivate: user!.isPrivate,
                    );
                  
                    context.go('/home');
                  }
                },
                child: const Text("Continue", style: TextStyle(color: Colors.white,)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GestureDetector(
                onTap: () {
                  // logic
<<<<<<< HEAD
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
=======
                  context.go('/home');
>>>>>>> b5a4cd3 (refactor: UPGRADE app to use go_router)
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