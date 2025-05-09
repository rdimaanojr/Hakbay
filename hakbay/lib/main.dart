import 'package:flutter/material.dart';
import 'package:hakbay/commons/bottom_navbar.dart';
import 'package:hakbay/firebase_options.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:hakbay/screens/init_interests_page.dart';
import 'package:hakbay/screens/init_travel_styles_page.dart';
import 'package:hakbay/screens/profile_page.dart';
import 'package:hakbay/screens/edit_profile_page.dart';
import 'package:hakbay/screens/signin_page.dart';
import 'package:hakbay/screens/signup_page.dart';
import 'package:hakbay/screens/similar_people_page';
import 'package:hakbay/screens/travel_plan_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/utils/logger.dart';

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

final GoRouter _router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const SignInPage(),
      routes: [
        GoRoute(
          path: "signup",
          builder: (context, state) => const SignUpPage(),
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: BottomNavbar(
            currentIndex: navigationShell.currentIndex,
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/home",
              builder: (context, state) => const TravelPlanPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/people",
              builder: (context, state) => const SimilarPeoplePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/profile",
              builder: (context, state) => ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: "/profile",
      builder: (context, state) => ProfilePage(),
      routes: [
        GoRoute(
          path: "edit",
          builder: (context, state) {
            final user = context.read<UserProvider>().user;
            return EditProfilePage(user: user);
          },
        ),
      ],
    ),
    GoRoute(
      path: "/people",
      builder: (context, state) => const SimilarPeoplePage(),
    ),
    GoRoute(
      path: "/init-interests",
      builder: (context, state) => const InitInterestsScreen(),
    ),
    GoRoute(
      path: "/init-travel-styles",
      builder: (context, state) => const InitTravelStylesScreen(),
    ),
  ],
);

class RootWidget extends StatelessWidget {
  const RootWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
