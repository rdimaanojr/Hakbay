import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/travel_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:hakbay/screens/notification_provider.dart';
import 'package:hakbay/utils/logger.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TravelPlanPage extends StatefulWidget {
  const TravelPlanPage({super.key});

  @override
  State<TravelPlanPage> createState() => _TravelPlanPageState();
}

class _TravelPlanPageState extends State<TravelPlanPage> {
  AppUser? user;
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = context.read<UserAuthProvider>().getCurrentUserUID() ?? '';
    _loadUserData();
    listenToNotif();
  }

  listenToNotif() {
    print("Listening to notif");
    NotificationProvider.onClickNotification.listen((payload) {});
  }

  Future<void> _loadUserData() async {
    try {
      await context.read<UserProvider>().fetchUserData(uid);
      final fetchedUser = context.read<UserProvider>().user;
      context.read<TravelPlanProvider>().fetchTravels(uid);

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

  // Formatting stuff
  String formatDateRange(DateTimeRange range) {
    final start = DateFormat('MMM d, yyyy').format(range.start);
    final end = DateFormat('MMM d, yyyy').format(range.end);
    return "$start - $end";
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // get the streams
    Stream<QuerySnapshot> travelStream =
        context.read<TravelPlanProvider>().getTravels;
    Stream<QuerySnapshot> sharedStream =
        context.read<TravelPlanProvider>().getSharedPlans;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Travels"),
          actions: [
            IconButton(
              // Scan QR logic
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'Scan QR Code',
              onPressed: () async {
                final scannedPlanId = await context.push('/qr-scanner');
                if (scannedPlanId == null || scannedPlanId is! String) return;
                
                final sharedTravel = await context.read<TravelPlanProvider>().fetchTravelById(scannedPlanId);

                if(sharedTravel == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Travel Plan not found.")),
                  );
                  return;
                }
                // Add to shared travel plans
                final userId = context.read<UserAuthProvider>().getCurrentUserUID();

                if(sharedTravel.sharedWith.contains(userId)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Already added travel plan!")),
                  );
                  return;
                }

                await context.read<TravelPlanProvider>().shareTravelPlan(sharedTravel, userId!);

                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Shared travel plan successfully!")),
                );

                context.push('/travel-details', extra: sharedTravel);
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor, 
            labelColor: Colors.white, 
            unselectedLabelColor: Colors.white70, 
            tabs: const [
              Tab(text: "My Travel Plans"),
              Tab(text: "Shared With Me"),
            ],
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push('/add-travel');
          },
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            buildTravels(stream: travelStream),
            buildTravels(stream: sharedStream),
          ]
        ) 
      ),
    );
  }

  Widget buildTravels({required Stream<QuerySnapshot> stream}) {
    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error encountered! ${snapshot.error}"),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return noTravelsWidget(context);
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 3 / 2,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                TravelPlan travel = TravelPlan.fromJson(
                  snapshot.data!.docs[index].data() as Map<String, dynamic>,
                );

                return GestureDetector(
                  onTap: () {
                    context.push('/travel-details', extra: travel);
                  },
                  child: Card(
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            travel.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  travel.location,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.date_range,
                                  size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  formatDateRange(travel.travelDate),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
  }

  Widget noTravelsWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "No Plans Yet? Plan a new trip!",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
