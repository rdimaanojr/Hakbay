import 'package:flutter/material.dart';
<<<<<<< HEAD
<<<<<<< HEAD
import 'package:hakbay/models/util_models.dart';
=======
import 'package:hakbay/commons/constants.dart';
<<<<<<< HEAD:hakbay/lib/screens/init_interests_screen.dart
import 'package:hakbay/screens/init_travel_styles.dart';
>>>>>>> 1e454cf (feat: IMPLEMENT models)
=======
>>>>>>> a3ce398 (refactor: REFACTOR code base):hakbay/lib/screens/init_interests_page.dart
=======
import 'package:hakbay/commons/constants.dart';
>>>>>>> 559569a (chore: merge)
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/utils/logger.dart';

class InitInterestsScreen extends StatefulWidget {
  const InitInterestsScreen({super.key});

  @override
  State<InitInterestsScreen> createState() => _InitInterestsScreenState();
}

class _InitInterestsScreenState extends State<InitInterestsScreen> {
  final List<String> selectedInterests = [];
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
                      Interests.all.map((interest) {
                        final isSelected = selectedInterests.contains(interest);
                        return GestureDetector(
                          onTap: () => toggleInterest(interest),
                          child: Chip(
                            label: Text(
                              interest,
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
                    selectedInterests
                        .map((interest) => Chip(
                          label: Text(
                            interest, 
                            style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                          )
                        ).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                ),
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
                      interests: selectedInterests,
                      travelStyles: user!.travelStyles,
                      isPrivate: user!.isPrivate,
                    );

                    context.go('/init-travel-styles');
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
<<<<<<< HEAD
=======
                  Navigator.pushNamedAndRemoveUntil(context, "/init-travel-styles", (route) => false);
>>>>>>> a800b17 (chore: ADD profile init screen routing)
=======

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/init-travel-styles",
                    (route) => false,
                  );
>>>>>>> 9dc5dae (chore: INTEGRATE interest and travel style to db)
=======
                  context.go('/init-travel-styles');

>>>>>>> b5a4cd3 (refactor: UPGRADE app to use go_router)
=======
                  context.go('/init-travel-styles');

>>>>>>> 559569a (chore: merge)
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
<<<<<<< HEAD
}
=======
}
>>>>>>> 559569a (chore: merge)
