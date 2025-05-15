import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/travel_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:hakbay/utils/logger.dart';
import 'package:intl/intl.dart';
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

  // Formatting stuff
  String formatDateRange(DateTimeRange range) {
    final start = DateFormat('MMM d, yyyy').format(range.start);
    final end = DateFormat('MMM d, yyyy').format(range.end);
    return "$start - $end";
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Stream<QuerySnapshot> travelStream = context.read<TravelPlanProvider>().getTravels;
    
    return Scaffold(
      appBar: AppBar(title: Text("My Travels"),),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-travel');
        },
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
          return Padding(
            padding: EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 10.0, 
                mainAxisSpacing: 10.0,
                childAspectRatio: 3 / 2, 
              ),
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                // Convert from JSON per travel plan
                TravelPlan travel = TravelPlan.fromJson(
                  snapshot.data?.docs[index].data() as Map<String, dynamic>,
                );

                // Use a Card to display each travel plan in the grid
                return GestureDetector(
                  onTap: (){
                    context.push('/travel-details', extra: travel);
                  },
                  onLongPress: () {
                    // TODO; Delete the travel plan by holding it down 
                  },
                  child: Card(
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            travel.name, 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.white70,),
                              SizedBox(width: 4,),
                              Expanded(
                                child: Text(
                                  travel.location, 
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 4,),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.white70,),
                              SizedBox(width: 4,),
                              Expanded(
                                child: Text(
                                  formatDateRange(travel.travelDate), 
                                  style: TextStyle(color: Colors.white70, fontSize: 12,),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                );
              },
            ),
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
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ],
      )
    ); 
  }
}