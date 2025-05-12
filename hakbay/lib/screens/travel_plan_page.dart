import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/travel_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:hakbay/utils/logger.dart';
import 'package:provider/provider.dart';

// This class shows our list of travel pages
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

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Stream<QuerySnapshot> travelStream = context.read<TravelPlanProvider>().getTravels;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("My Travels"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-travel');
        },
        foregroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),

      // Build the Stream
      body: StreamBuilder<QuerySnapshot>(
        stream: travelStream,
        builder: (context, snapshot) {
          // Check for errors and if the database is empty
          if (snapshot.hasError) {
            return Center(child: Text("Error encountered! ${snapshot.error}"));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return noTravelsWidget(context);
          }

          // Build a gridview for the travel plans  
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns in the grid
              crossAxisSpacing: 10.0, // Spacing between columns
              mainAxisSpacing: 10.0, // Spacing between rows
              childAspectRatio: 3 / 2, // Aspect ratio of each grid item
            ),
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              // Convert from JSON per travel plan
              TravelPlan travel = TravelPlan.fromJson(
                snapshot.data?.docs[index].data() as Map<String, dynamic>,
              );

              // Use a Card to display each travel plan in the grid
              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => SizedBox()
                        // TravelPlanDetails(travel: travelplan),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        travel.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        travel.startDate.toString(),
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => SizedBox()
                                  // TravelModal(type: 'Edit', entry: travel),
                              );
                            },
                            icon: const Icon(Icons.create),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => SizedBox()
                                  // TravelModal(type: 'Delete', entry: travel),
                              );
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Widget to show that there are still no travel plans
  Widget noTravelsWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No Plans Yet? Plan a new trip!",
            style: TextStyle(fontSize: 20),
          ),
        ],
      )
    ); 
  }
}