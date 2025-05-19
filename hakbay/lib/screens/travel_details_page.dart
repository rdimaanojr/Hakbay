import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';
=======
import 'package:hakbay/api/firebase_travel_api.dart';
>>>>>>> 1766f4a (feat: added itinerary form)
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/travel_provider.dart';
<<<<<<< HEAD
import 'package:hakbay/screens/notification_provider.dart';
=======
import 'package:hakbay/providers/user_provider.dart';
>>>>>>> ea9343f (feat: Shared Users can be viewed on each travel plan)
import 'package:hakbay/screens/share_qr_code.dart';
import 'package:hakbay/screens/travel_itinerary.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TravelPlanDetails extends StatefulWidget {
  final TravelPlan travel;

  const TravelPlanDetails({super.key, required this.travel});

  @override
  State<TravelPlanDetails> createState() => _TravelPlanDetailsState();
}

class _TravelPlanDetailsState extends State<TravelPlanDetails> {
  late TravelPlan travelPlan;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    travelPlan = widget.travel;
    context.read<TravelPlanProvider>().fetchItineraries(travelPlan.planId!);
<<<<<<< HEAD

    // initializeNotifications();
    // tz.initializeTimeZones();
=======
    context.read<UserProvider>().fetchSharedUsers(travelPlan.sharedWith);
    initializeNotifications();
    tz.initializeTimeZones();
>>>>>>> ea9343f (feat: Shared Users can be viewed on each travel plan)
  }

  String formatDateRange(DateTimeRange range) {
    final start = DateFormat('MMM d, yyyy').format(range.start);
    final end = DateFormat('MMM d, yyyy').format(range.end);
    return "$start - $end";
  }

  // void checkForUpcomingItineraries(List<ItineraryItem> items) {
  //   final now = DateTime.now();
    
  //   for (final item in items) {
  //     // Check if the itinerary is within the next 24 hours
  //     if (item.date.isAfter(now.subtract(const Duration(days: 1))) && 
  //         item.date.isBefore(now.add(const Duration(days: 1)))) {
  //       scheduleNotification(item);
  //     }
  //   }
  // }

  // Future<void> scheduleNotification(ItineraryItem item) async {
  //   final androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'itinerary_channel',
  //     'Itinerary Notifications',
  //     channelDescription: 'Notifications for upcoming itinerary items',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //   );
    
  //   final platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //   );
    
  //   // Convert the item's date and time to local timezone
  //   final scheduledDate = tz.TZDateTime.from(
  //     DateTime(item.date.year, item.date.month, item.date.day, 
  //             item.startTime.hour, item.startTime.minute),
  //     tz.local,
  //   );
    
  //   // Schedule notification 1 hour before the event
  //   final notificationTime = scheduledDate.subtract(const Duration(hours: 23));
    
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     item.hashCode, // Unique ID for the notification
  //     'Upcoming Itinerary: ${item.name}',
  //     'Starts at ${DateFormat.Hm().format(item.startTime)} at ${item.location ?? "unknown location"}',
  //     notificationTime,
  //     platformChannelSpecifics,
  //     matchDateTimeComponents: DateTimeComponents.time, androidScheduleMode: AndroidScheduleMode.exact,
  //   );
  // }

  // Future<void> initializeNotifications() async {
  //   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
  //   const AndroidInitializationSettings initializationSettingsAndroid = 
  //     AndroidInitializationSettings('app_icon');
      
  //   final InitializationSettings initializationSettings = 
  //     InitializationSettings(android: initializationSettingsAndroid);
      
  //   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }

  // Future<void> scheduleTravelPlanNotification() async {
  //   final androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'travel_plan_channel',
  //     'Travel Plan Notifications',
  //     channelDescription: 'Notifications for upcoming travel plans',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //   );

  //   final platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //   );

  //   final scheduledDate = tz.TZDateTime.from(
  //     DateTime(travelPlan.travelDate.start.year, travelPlan.travelDate.start.month, travelPlan.travelDate.start.day),
  //     tz.local,
  //   ).subtract(const Duration(days: 1)); // 1 day before

  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     travelPlan.planId.hashCode, // Unique ID
  //     'Upcoming Travel: ${travelPlan.name}',
  //     'Your trip to ${travelPlan.location} starts soon!',
  //     scheduledDate,
  //     platformChannelSpecifics,
  //     matchDateTimeComponents: DateTimeComponents.dateAndTime,
  //     androidScheduleMode: AndroidScheduleMode.exact,
  //   );
  // }

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
    Stream<QuerySnapshot> sharedUserStream = context.read<UserProvider>().getSharedUsers;

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
        padding: const EdgeInsets.all(12),
        children: [
          Column(
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

              // Details (if there are any)
              if (travelPlan.details != null && travelPlan.details!.isNotEmpty) ...[
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
              ElevatedButton.icon(
                icon: Icon(Icons.notifications_active_outlined),
                onPressed: () {
                  NotificationProvider().showNotification(title: "Travel Plan", body: "Upcoming in 3 days", payload: "simple");
                },
                label: (Text("Sample notif")),
              ),

              // Shared With Users Section (If there are any)
              StreamBuilder<QuerySnapshot>(
                stream: sharedUserStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.white,));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SizedBox();
                  }

                  final users = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return AppUser.fromJson(data);
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Shared With",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: users.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Column(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey[800],
                                  backgroundImage: user.profilePic != null
                                      ? MemoryImage(base64Decode(user.profilePic!))
                                      : null,
                                  child: user.profilePic == null
                                      ? const Icon(Icons.person, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  user.username,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

              // Itinerary Section
              Text(
                "Itinerary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: itineraryStream,
                  builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(12),
                      child: Text("No itinerary items yet.", style: TextStyle(color: Colors.white70)),
                    );
                  }

                  final items = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ItineraryItem.fromJson(data);
                  }).where((item) {
                    // Only show items where the date is within the travel date range
                    return item.date.isAfter(travelPlan.travelDate.start.subtract(Duration(days: 1))) &&
                    item.date.isBefore(travelPlan.travelDate.end.add(Duration(days: 1)));
                  }).toList()
                    ..sort((a, b) {
                    final dateCompare = a.date.compareTo(b.date);
                    if (dateCompare != 0) return dateCompare;
                    return a.startTime.compareTo(b.startTime);
                    });

                    if (items.isEmpty) {
                      return Padding(
                      padding: EdgeInsets.all(12),
                      child: Text("No itinerary items within travel dates.", style: TextStyle(color: Colors.white70)),
                      );
                    }

                    // WidgetsBinding.instance.addPostFrameCallback((_) {
                    //   checkForUpcomingItineraries(items);
                    // });

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
                          margin: EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
<<<<<<< HEAD
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
>>>>>>> 0c826f7 (fix: display only the itineraries that are within the range of travel plan)
=======
                            icon: Icon(Icons.delete, color: Colors.redAccent),
>>>>>>> ea9343f (feat: Shared Users can be viewed on each travel plan)
                            tooltip: 'Delete',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Itinerary Item'),
                                  content: Text('Are you sure you want to delete this itinerary item?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text('Delete', style: TextStyle(color: Colors.red)),
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
                                    SnackBar(content: Text('Itinerary item deleted')),
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