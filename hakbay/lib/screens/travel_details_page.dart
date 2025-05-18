import 'package:cloud_firestore/cloud_firestore.dart';
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
    context.read<TravelPlanProvider>().fetchItineraries(travelPlan.planId!);
  }

  String formatDateRange(DateTimeRange range) {
    final start = DateFormat('MMM d, yyyy').format(range.start);
    final end = DateFormat('MMM d, yyyy').format(range.end);
    return "$start - $end";
  }

  void menuOptionSelected(String choice) async {
    if (choice == 'Edit') {
      final result = await context.push('/edit-travel', extra: travelPlan);
      if (result is TravelPlan) {
        setState(() => travelPlan = result);
      }
    } else if (choice == 'Delete') {
      final shouldDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Travel Plan'),
          content: const Text('Are you sure you want to delete this travel plan?'),
          actions: [
            TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
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
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    Stream<QuerySnapshot> itineraryStream = context.read<TravelPlanProvider>().getItineraryItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(travelPlan.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: menuOptionSelected,
            itemBuilder: (context) => const [
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
                  Provider<FirebaseTravelApi>.value(value: FirebaseTravelApi()),
                  ChangeNotifierProvider<TravelPlanProvider>.value(
                    value: Provider.of<TravelPlanProvider>(context, listen: false),
                  ),
                ],
                child: AddItineraryPage(travelPlan: travelPlan),
              ),
            ),
          );
        },
        tooltip: 'Add Itinerary',
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Destination
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      travelPlan.location,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dates
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    formatDateRange(travelPlan.travelDate),
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Details
              if (travelPlan.details != null && travelPlan.details!.isNotEmpty) ...[
                Row(
                  children: const [
                    Icon(Icons.notes, color: Colors.white70),
                    SizedBox(width: 8),
                    Text(
                      "Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  travelPlan.details!,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 24),
              ],

              // Itinerary Section
              const Text(
                "Itinerary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 400,
                child: StreamBuilder<QuerySnapshot>(
                  stream: itineraryStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text("No itinerary items yet.", style: TextStyle(color: Colors.white70)),
                      );
                    }

                    final items = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ItineraryItem.fromJson(data);
                    }).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.location != null) Text("Location: ${item.location}"),
                                Text("Date: ${DateFormat.yMMMMd().format(item.date)}"),
                                Text("Start: ${DateFormat.Hm().format(item.startTime)}"),
                                Text("End: ${DateFormat.Hm().format(item.endTime)}"),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ]
      ),
    );
  }
}
