import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/travel_provider.dart';
import 'package:place_picker_google/place_picker_google.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// This class is our add an expense page form
class TravelPlanFormPage extends StatefulWidget {
  const TravelPlanFormPage({super.key});

  @override
  State<TravelPlanFormPage> createState() => _TravelPlanFormPageState();
}

class _TravelPlanFormPageState extends State<TravelPlanFormPage> {
  // GlobalKey for our form validation later
  final travelFormGlobalKey = GlobalKey<FormState>();
  
  // Using controllers for the text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  DateTimeRange? travelDate;

  double? selectedLat;
  double? selectedLng;

  // Something to hold our new travelplan for the provider
  late TravelPlan newTravelPlan;

  // Function for the onPressed() add expense button
  void saveForm() async {
    // We first validate,
    if (travelFormGlobalKey.currentState!.validate()) {
      // then set state (wow rhymes)
      setState(() {
        travelFormGlobalKey.currentState?.save(); 
      });
      // Let's check and see which user is signed in
      final userUID = context.read<UserAuthProvider>().getCurrentUserUID();

      // Create an instance of a travel plan
      newTravelPlan = TravelPlan(
        name: nameController.text.trim(),
        travelDate: travelDate!,
        location: locationController.text.trim(),
        details: detailsController.text,
        uid: userUID,
      );
      
      // I forgot to add it in the database lmaoo (spent 6 minutes debugging)
      await context.read<TravelPlanProvider>().addTravel(newTravelPlan);

      resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Travel Plan Created Successfully!')),
      );

      context.pop();
    }
  }

  // Function to reset the form
  void resetForm() {
    setState(() {
      travelFormGlobalKey.currentState!.reset();
      // Clear the values of the textfields
      nameController.clear();
      locationController.clear();
      detailsController.clear();
      travelDate = null;
    });
  }

  String formatDateRange(DateTimeRange range) {
    final start = DateFormat('MMM d, yyyy').format(range.start);
    final end = DateFormat('MMM d, yyyy').format(range.end);
    return "$start - $end";
  }

  @override 
  // This part ensures no left-over value in our fields
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  // The scaffold main widget 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The appbar section
      appBar: AppBar(title: Text('Add Travel Plan'),),
      
      // The main body will be the Form Widget
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: travelFormGlobalKey,
          child: ListView(
            children: [
              // Trip name field
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Trip Name",
                    suffixIcon: Icon(Icons.flight, color: Colors.white70)
                  ),
                  style: TextStyle(color: Colors.white),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a name.";
                    }
                    return null;
                  },),
              ),

              // Location field
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () async {
                    final result = await context.push<LocationResult>('/location_picker');

                    if (result != null) {
                      final adminArea2 = result.subLocalityLevel2?.longName;
                      final adminArea = result.administrativeAreaLevel1?.longName;
                      final country = result.country?.longName ?? result.name;

                      final resolvedLocation = adminArea2 ?? adminArea ?? '';
                    
                      locationController.text = "$resolvedLocation, $country";
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
                )
              ),

              // Travel Date Range field
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: context, 
                      firstDate: DateTime.now(), 
                      lastDate: DateTime(3000),
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
                    if (range != null) {
                      setState(() {
                        travelDate = range;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Date",
                        suffixIcon: Icon(Icons.date_range, color: Colors.white70)
                      ),
                      controller: TextEditingController(
                        text: travelDate != null ? formatDateRange(travelDate!) : '',
                      ),
                      validator: (value) {
                        if (travelDate == null) {
                          return "Please select a date.";
                        }
                        return null;
                      },
                    ),
                  ),
                )
              ),       
              // Details (optional) field 
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: "Details", hintText: "Enter any notes...", alignLabelWithHint: true),
                  controller: detailsController,
                  maxLines: 3,
                ),
              ),
              SizedBox(height: 24),
              // Save button
              ElevatedButton(
                onPressed: saveForm,
                child: Text("Save", style: TextStyle(color: Colors.white,)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}