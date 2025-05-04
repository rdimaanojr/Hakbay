import 'package:flutter/material.dart';
import 'package:hakbay/firebase_options.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:hakbay/screens/homepage.dart';
import 'package:hakbay/screens/profile_page.dart';
import 'package:hakbay/screens/similar_people_page';
import 'package:hakbay/screens/travel_plan_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserAuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const RootWidget(),
    ),
  );
}

class RootWidget extends StatelessWidget {
  const RootWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const HomePage(),
        "/home": (context) => const TravelPlanPage(),
        "/profile": (context) => const ProfilePage(),
        "/people": (context) => const SimilarPeoplePage(),
      }
    );
  }
}