import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/providers/travel_provider.dart';
import 'package:intl/intl.dart';
import 'package:place_picker_google/place_picker_google.dart';
import 'package:provider/provider.dart';

class EditItineraryPage extends StatefulWidget {
  final ItineraryItem itinerary;
  final TravelPlan travelPlan;

  const EditItineraryPage({super.key, required this.itinerary, required this.travelPlan});

  @override
  State<EditItineraryPage> createState() => _EditItineraryPageState();
}

class _EditItineraryPageState extends State<EditItineraryPage> {
  final editItineraryFormKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController locationController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.itinerary.name);
    locationController = TextEditingController(text: widget.itinerary.location);
    _selectedDate = widget.itinerary.date;
    _selectedStartTime = TimeOfDay.fromDateTime(widget.itinerary.startTime);
    _selectedEndTime = TimeOfDay.fromDateTime(widget.itinerary.endTime);
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  Future<void> editDate() async {
    final newDate = await showDatePicker(
      context: context,
      firstDate: widget.travelPlan.travelDate.start,
      lastDate: widget.travelPlan.travelDate.end,
      initialDate: _selectedDate,
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

    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
    }
  }

  Future<void> editStartTime() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF1DB954),
              surface: Color(0xFF102820),
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (newTime != null) {
      setState(() {
        _selectedStartTime = newTime;
      });
    }
  }

  Future<void> editEndTime() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF1DB954),
              surface: Color(0xFF102820),
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (newTime != null) {
      setState(() {
        _selectedEndTime = newTime;
      });
    }
  }

  void _saveChanges() {
    if (editItineraryFormKey.currentState!.validate()) {
      final updatedItinerary = ItineraryItem(
        id: widget.itinerary.id,
        name: nameController.text.trim(),
        location: locationController.text.trim(),
        date: _selectedDate,
        startTime: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedStartTime.hour,
          _selectedStartTime.minute,
        ),
        endTime: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedEndTime.hour,
          _selectedEndTime.minute,
        ),
      );

      context.read<TravelPlanProvider>().updateItinerary(widget.itinerary.id!, updatedItinerary);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Itinerary Plan Edited Successfully!')),
      );

      context.pop(updatedItinerary);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Itinerary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: editItineraryFormKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                style: TextStyle(color: Colors.white),
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  suffixIcon: Icon(Icons.map, color: Colors.white70)
                ),
                validator: (value) => value == null || value.trim().isEmpty ? "Please enter itinerary name" : null,
              ),
              SizedBox(height: 12),

              // Location
              GestureDetector(
                onTap: () async {

                  final result = await context.push<LocationResult>('/location_picker');

                  if (result != null) {
                    final locality = result.locality?.longName;
                    final sublocality2 = result.subLocalityLevel2?.longName;
                    final sublocality = result.subLocalityLevel1?.longName;
                    final adminArea2 = result.subLocalityLevel2?.longName;
                    final adminArea = result.administrativeAreaLevel1?.shortName;

                    // Prefer locality > sublocality > admin area
                    final resolvedLocation = sublocality2 ?? sublocality ?? locality ?? adminArea2 ?? '';

                    locationController.text = "$resolvedLocation, $adminArea";
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Location",
                      suffixIcon: Icon(Icons.location_on, color: Colors.white70)
                    ),
                    style: TextStyle(color: Colors.white),
                    controller: locationController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a location.";
                      }
                      return null;
                    },
                  ),
                ),
              ),
              
              SizedBox(height: 12),
              GestureDetector(
                onTap: editDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Travel Date",
                    suffixIcon: Icon(Icons.date_range, color: Colors.white70)
                  ),
                  child: Text(
                    formatDate(_selectedDate),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              // Time
              SizedBox(height: 12),
              GestureDetector(
                onTap: editStartTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Start Time",
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(_selectedStartTime),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Icon(Icons.access_time, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: editEndTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "End Time",
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(_selectedEndTime),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Icon(Icons.access_time, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text("Save Changes", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
