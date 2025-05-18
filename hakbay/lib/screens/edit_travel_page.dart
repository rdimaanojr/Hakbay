import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hakbay/providers/travel_provider.dart';

class EditTravelPlanPage extends StatefulWidget {
  final TravelPlan travel;

  const EditTravelPlanPage({super.key, required this.travel});

  @override
  State<EditTravelPlanPage> createState() => _EditTravelPlanPageState();
}

class _EditTravelPlanPageState extends State<EditTravelPlanPage> {
  final formGlobalKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController detailsController;
  late DateTimeRange dateRange;

  @override
  void initState() {
    super.initState();
    // store current values 
    nameController = TextEditingController(text: widget.travel.name);
    locationController = TextEditingController(text: widget.travel.location);
    detailsController = TextEditingController(text: widget.travel.details ?? '');
    dateRange = widget.travel.travelDate;
  }

  // formatting function
  String formatDateRange(DateTimeRange range) {
    final start = DateFormat('MMM d, yyyy').format(range.start);
    final end = DateFormat('MMM d, yyyy').format(range.end);
    return "$start - $end";
  }

  // Date Range Picker function
  Future<void> editDateRange() async {
    final newRange = await showDateRangePicker(
      context: context,
      firstDate: dateRange.start.isBefore(DateTime.now())
        ? dateRange.start
        : DateTime.now(),
      lastDate: DateTime(3000),
      initialDateRange: dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF1DB954),
              surface: Color(0xFF102820),
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white),
            ),
          ),
        child: child!,
        );
      },
    );

    if (newRange != null) {
      setState(() {
        dateRange = newRange;
      });
    }
  }

  void _saveChanges() {
    if (formGlobalKey.currentState!.validate()) {
      final updatedTravel = TravelPlan(
        uid: widget.travel.uid,
        planId: widget.travel.planId,
        name: nameController.text.trim(),
        location: locationController.text.trim(),
        details: detailsController.text.trim(),
        travelDate: dateRange,
      );

      // call provider to update
      context.read<TravelPlanProvider>().editTravel(widget.travel.planId!, updatedTravel);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Travel Plan Edited Successfully!'),),
      );

      context.pop(updatedTravel); // Return to previous screen
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    locationController.dispose();
    detailsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Travel Plan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formGlobalKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                style: TextStyle(color: Colors.white),
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) => value == null || value.trim().isEmpty ? "Please enter a name" : null,
              ),
              SizedBox(height: 12),

              // Location
              TextFormField(
                style: TextStyle(color: Colors.white),
                controller: locationController,
                decoration: InputDecoration(labelText: "Location"),
                validator: (value) => value == null || value.trim().isEmpty ? "Please enter a location" : null,
              ),
              SizedBox(height: 12),

              // Date Range Picker
              GestureDetector(
                onTap: editDateRange,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Travel Dates",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDateRange(dateRange),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Icon(Icons.calendar_today, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),

              // Details
              TextFormField(
                style: TextStyle(color: Colors.white),
                controller: detailsController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Details",
                  alignLabelWithHint: true,
                ),
              ),

              SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16),
                ),
                onPressed: _saveChanges,
                child: Text("Save Changes", style: TextStyle(color: Colors.white),),
              )
            ],
          ),
        ),
      ),
    );
  }
}
