import 'package:flutter/material.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:intl/intl.dart';

class TravelPlanDetails extends StatefulWidget {
  final TravelPlan travel;

  const TravelPlanDetails({super.key, required this.travel});

  @override
  State<TravelPlanDetails> createState() => _TravelPlanDetailsState();
}

class _TravelPlanDetailsState extends State<TravelPlanDetails> {
  // Formatting function
  String formatDateRange(DateTimeRange range) {
    final start = DateFormat('MMM d, yyyy').format(range.start);
    final end = DateFormat('MMM d, yyyy').format(range.end);
    return "$start - $end";
  }

  // Pop up menu function
  void menuOptionSelected(String choice) {
    if (choice == 'Edit') {
      // TODO: Navigate to edit screen (antok na ako)
    } else if (choice == 'Delete') {
      // TODO: Confirm and delete travel plan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.travel.name),
        actions: [
          PopupMenuButton(
            onSelected: menuOptionSelected,
            itemBuilder: (context) =>[
              PopupMenuItem(value: 'Edit', child: Text('Edit'),),
              PopupMenuItem(value: 'Delete', child: Text('Delete'),),
            ]
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add itinerary page
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
                    widget.travel.location,
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
                  formatDateRange(widget.travel.travelDate),
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Details (optional)
            if (widget.travel.details != null && widget.travel.details!.isNotEmpty)
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
                    widget.travel.details!,
                    style: TextStyle(fontSize: 16, color: Colors.white70,),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            // Itineraries placeholder
            Text(
              "Itinerary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 12),

            // Placeholder for our itineraries for now
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
