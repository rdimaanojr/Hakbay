import 'package:flutter/material.dart';
import 'package:hakbay/commons/bottom_navbar.dart';
import 'package:hakbay/firebase_options.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/screens/notification_provider.dart';
import 'package:hakbay/providers/travel_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:hakbay/screens/edit_itinerary_page.dart';
import 'package:hakbay/screens/edit_travel_page.dart';
import 'package:hakbay/screens/scan_qr_code.dart';
import 'package:hakbay/screens/travel_details_page.dart';
import 'package:hakbay/screens/travel_form_page.dart';
import 'package:hakbay/screens/init_interests_page.dart';
import 'package:hakbay/screens/init_travel_styles_page.dart';
import 'package:hakbay/screens/profile_page.dart';
import 'package:hakbay/screens/edit_profile_page.dart';
import 'package:hakbay/screens/signin_page.dart';
import 'package:hakbay/screens/signup_page.dart';
import 'package:hakbay/screens/similar_people_page.dart';
import 'package:hakbay/screens/travel_plan_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationProvider().initNotification();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserAuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => TravelPlanProvider()),
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
          ],
        ),
      ],
    ),
    GoRoute(
      path: "/init-interests",
      builder: (context, state) => const InitInterestsScreen(),
    ),
    GoRoute(
      path: "/init-travel-styles",
      builder: (context, state) => const InitTravelStylesScreen(),
    ),
    GoRoute(
      path: "/add-travel",
      builder: (context, state) => const TravelPlanFormPage(),
    ),
    GoRoute(
      path: "/travel-details",
      builder: (context, state) {
        final travel = state.extra as TravelPlan;
        return TravelPlanDetails(travel: travel);
      } 
    ),
    GoRoute(
      path: '/edit-travel',
      builder: (context, state) {
        final travel = state.extra as TravelPlan;
        return EditTravelPlanPage(travel: travel);
      },
    ),
    GoRoute(
<<<<<<< HEAD
      path: '/qr-scanner',
      builder: (context, state) => QrScannerPage(),
=======
      path: '/edit-itinerary',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final ItineraryItem item = data['item'];
        final TravelPlan travelPlan = data['travelPlan'];
        return EditItineraryPage(itinerary: item, travelPlan: travelPlan);
      },
>>>>>>> f7a23c0 (feat: added edit and delete itinerary method)
    ),
  ],
);

class RootWidget extends StatelessWidget {
  const RootWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hakbay',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF101F1B),
        primaryColor: Color(0xFF1DB954),
        fontFamily: 'Poppins',
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF101F1B),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1DB954),
          foregroundColor: Colors.white, 
        ),
        cardColor: Color(0xFF1A2E28),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1A2E28),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white60),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Color(0xFF1A2E28),
          indicatorColor: Color(0xFF1DB954),
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(color: Colors.white),),
          iconTheme: WidgetStateProperty.all(
            IconThemeData(color: Colors.white),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1DB954),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)
            )
          ),
        )
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
