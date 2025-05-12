import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/providers/auth_provider.dart';
import 'package:hakbay/providers/travel_provider.dart';
import 'package:provider/provider.dart';

// This class is our add an expense page form
class TravelPlanFormPage extends StatefulWidget {
  const TravelPlanFormPage({super.key});

  @override
  State<TravelPlanFormPage> createState() => _TravelPlanFormPageState();
}

class _TravelPlanFormPageState extends State<TravelPlanFormPage> {
  // GlobalKey for our form validation later
  final formGlobalKey = GlobalKey<FormState>();
  
  // Using controllers for the text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  // Something to hold our new travelplan for the provider
  late TravelPlan newTravelPlan;

  // Function for the onPressed() add expense button
  void saveForm() async {
    // We first validate,
    if (formGlobalKey.currentState!.validate()) {
      // then set state (wow rhymes)
      setState(() {
        formGlobalKey.currentState?.save(); 
      });
      // Let's check and see which user is signed in
      final userUID = context.read<UserAuthProvider>().getCurrentUserUID();

      // Create an instance of a travel plan
      newTravelPlan = TravelPlan(
        name: nameController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        location: locationController.text,
        uid: userUID
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
      formGlobalKey.currentState!.reset();
      // Clear the values of the textfields
      nameController.clear();
      locationController.clear();
      _startDate = null;
      _endDate = null;
    });
  }

  // Function to pick our start and end date
  Future<void> pickDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override 
  // This part ensures no left-over value in our fields
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    super.dispose();
  }

  // The scaffold main widget 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The appbar section
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Create Travel Plan'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          }
        ),
      ),
      
      // The main body will be the Form Widget (SingleChildScrollView to make it scrollable)
      body: SingleChildScrollView(
        child: Form(
          key: formGlobalKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              createNameField(),
              const SizedBox(height: 16),
              createLocationField(),
              const SizedBox(height: 16),
              createDatePickerField('Start Date', _startDate, true),
              const SizedBox(height: 16),
              createDatePickerField('End Date', _endDate, false),
              const SizedBox(height: 32),
              createAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  // This widget returns a textformfield to create our name field
  Widget createNameField(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        // This part is the box design
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Name",
        ),
        // the nameController for the value later
        controller: nameController,
        // This part is for the validate feature of the form
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a name.";
          }
          return null;
        },
      ),
    );
  }

  // Location Field Widget
  Widget createLocationField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Location",
        ),
        controller: locationController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a location.";
          }
          return null;
        },
      ),
    );
  }

  // This widget is to choose the date of the travel plan
  Widget createDatePickerField(String label, DateTime? date, bool isStartDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date == null
                  ? 'No $label selected'
                  : '$date',
            ),
          ),
          ElevatedButton(
            onPressed: () => pickDate(context, isStartDate),
            child: Text('Select $label'),
          ),
        ],
      ),
    );
  }

  Widget createAddButton() {
    return ElevatedButton(
      onPressed: saveForm,
      child: const Text("Create Travel Plan"),
    );
  }
}