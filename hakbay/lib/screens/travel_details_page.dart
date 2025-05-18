import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';
=======
import 'package:hakbay/api/firebase_travel_api.dart';
>>>>>>> 1766f4a (feat: added itinerary form)
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/providers/travel_provider.dart';
import 'package:hakbay/screens/travel_itinerary.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TravelPlanDetails extends StatefulWidget {
  final TravelPlan travel;

  const TravelPlanDetails({super.key, required this.travel});

  @override
  State<TravelPlanDetails> createState() => _TravelPlanDetailsState();
}

class _TravelPlanDetailsState extends State<TravelPlanDetails> {
  late TravelPlan travelPlan;

  @override
  void initState() {
    super.initState();
    travelPlan = widget.travel;
  }

  // Formatting function
  String formatDateRange(DateTimeRange range) {
    final start = DateFormat('MMM d, yyyy').format(range.start);
    final end = DateFormat('MMM d, yyyy').format(range.end);
    return "$start - $end";
  }

  // Pop up menu function
  void menuOptionSelected(String choice) async {
    if (choice == 'Edit') {
      // Call edit travel plan page
      final result = await context.push('/edit-travel', extra: travelPlan);

      if (result is TravelPlan) {
        setState(() {
          travelPlan = result;
        });
      }
    } else if (choice == 'Delete') {
      final shouldDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Travel Plan'),
          content: const Text('Are you sure you want to delete this travel plan?'),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (shouldDelete == true) {
        await context.read<TravelPlanProvider>().deleteTravel(travelPlan.planId!);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Travel Plan Deleted!')),
        );

        context.pop(); // Go back after deletion
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(travelPlan.name),
        actions: [
          PopupMenuButton(
            onSelected: menuOptionSelected,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Edit', child: Text('Edit')),
              PopupMenuItem(value: 'Delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultiProvider(
                providers: [
                  Provider<FirebaseTravelApi>.value(
                    value: FirebaseTravelApi(),
                  ),
                  ChangeNotifierProvider<TravelPlanProvider>.value(
                    value: Provider.of<TravelPlanProvider>(context, listen: false),
                  ),
                ],
                child: AddItineraryPage(travelPlan: widget.travel),
              ),
            ),
          );
        },
        tooltip: 'Add Itinerary',
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white70),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    travelPlan.location,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Dates
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  formatDateRange(travelPlan.travelDate),
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Details (optional)
            if (travelPlan.details != null && travelPlan.details!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes, color: Colors.white70),
                      SizedBox(width: 8),
                      Text(
                        "Details",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    travelPlan.details!,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 24),
                ],
              ),

            // Itinerary placeholder
            Text(
              "Itinerary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white10,
              ),
              child: Center(
                child: Text(
                  "No itineraries added yet.",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
