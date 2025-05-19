import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';
=======
import 'package:hakbay/api/firebase_travel_api.dart';
>>>>>>> 1766f4a (feat: added itinerary form)
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/providers/travel_provider.dart';
import 'package:hakbay/screens/share_qr_code.dart';
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
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: Theme.of(context).cardColor,
                context: context, 
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => ShareQrCode(planId: travelPlan.planId!),
              );
            },
          ),
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

                StreamBuilder<QuerySnapshot>(
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
                  }).where((item) {
                    // Only show items where the date is within the travel date range
                    return item.date.isAfter(travelPlan.travelDate.start.subtract(const Duration(days: 1))) &&
                    item.date.isBefore(travelPlan.travelDate.end.add(const Duration(days: 1)));
                  }).toList()
                    ..sort((a, b) {
                    final dateCompare = a.date.compareTo(b.date);
                    if (dateCompare != 0) return dateCompare;
                    return a.startTime.compareTo(b.startTime);
                    });

                    if (items.isEmpty) {
                      return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text("No itinerary items within travel dates.", style: TextStyle(color: Colors.white70)),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Card(
<<<<<<< HEAD
                        color: Theme.of(context).cardColor,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: Column(
<<<<<<< HEAD
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.location != '')
                                Text("Location: ${item.location}", style: TextStyle(color: Colors.white70)),
                              Text("Date: ${DateFormat.yMMMMd().format(item.date)}", style: TextStyle(color: Colors.white70)),
                              Text("Start: ${DateFormat.Hm().format(item.startTime)}", style: TextStyle(color: Colors.white70)),
                              Text("End: ${DateFormat.Hm().format(item.endTime)}", style: TextStyle(color: Colors.white70)),
                            ],
=======
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.location != null)
                            Text("Location: ${item.location}", style: TextStyle(color: Colors.white70)),
                            Text("Date: ${DateFormat.yMMMMd().format(item.date)}", style: TextStyle(color: Colors.white70)),
                            Text("Start: ${DateFormat.Hm().format(item.startTime)}", style: TextStyle(color: Colors.white70)),
                            Text("End: ${DateFormat.Hm().format(item.endTime)}", style: TextStyle(color: Colors.white70)),
                          ],
                          ),
                          onTap: () => context.push('/edit-itinerary', extra: item),
                          trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
=======
                          color: Theme.of(context).cardColor,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.location != null)
                                Text("Location: ${item.location}", style: TextStyle(color: Colors.white70)),
                                Text("Date: ${DateFormat.yMMMMd().format(item.date)}", style: TextStyle(color: Colors.white70)),
                                Text("Start: ${DateFormat.Hm().format(item.startTime)}", style: TextStyle(color: Colors.white70)),
                                Text("End: ${DateFormat.Hm().format(item.endTime)}", style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                            onTap: () => context.push('/edit-itinerary', extra: {'item': item, 'travelPlan': travelPlan}),
                            trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
>>>>>>> 0c826f7 (fix: display only the itineraries that are within the range of travel plan)
                            tooltip: 'Delete',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Itinerary Item'),
                                  content: const Text('Are you sure you want to delete this itinerary item?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
<<<<<<< HEAD
                              await context.read<TravelPlanProvider>().deleteItinerary(item.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Itinerary item deleted')),
                              );
                            }
                          },
>>>>>>> f7a23c0 (feat: added edit and delete itinerary method)
=======
                                await context.read<TravelPlanProvider>().deleteItinerary(item.id!);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Itinerary item deleted')),
                                  );
                                }
                              }
                            },
>>>>>>> 0c826f7 (fix: display only the itineraries that are within the range of travel plan)
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}