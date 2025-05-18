import 'package:flutter/material.dart';
import 'package:hakbay/api/firebase_travel_api.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/providers/travel_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddItineraryPage extends StatefulWidget {
  final TravelPlan travelPlan;
  final ItineraryItem? existingItem;

  const AddItineraryPage({
    Key? key,
    required this.travelPlan,
    this.existingItem,
  }) : super(key: key);

  @override
  _AddItineraryPageState createState() => _AddItineraryPageState();
}

class _AddItineraryPageState extends State<AddItineraryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  late DateTime _selectedStartTime;
  late DateTime _selectedEndTime;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      _nameController.text = widget.existingItem!.name;
      _locationController.text = widget.existingItem!.location!;
      _selectedStartTime = widget.existingItem!.startTime;
      _selectedEndTime = widget.existingItem!.endTime;
      _selectedDate = widget.existingItem!.date;
    } else {
      _selectedDate = widget.travelPlan.travelDate.start;
      _selectedStartTime = DateTime.now();
      _selectedEndTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    final start = DateFormat('MMM d, yyyy').format(date);
    return start;
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<FirebaseTravelApi>(context);
    final provider = Provider.of<TravelPlanProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingItem != null ? 'Edit Activity' : 'Add Activity',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveItinerary(api, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date For Itinerary
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context, 
                      initialDate: _selectedDate,
                      firstDate: widget.travelPlan.travelDate.start, 
                      lastDate: widget.travelPlan.travelDate.end,
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
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Itinerary Date"
                      ),
                      controller: TextEditingController(
                        text: formatDate(_selectedDate)
                      ),
                    ),
                  ),
                ),
              ),       
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Activity Name*',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Location',
                  suffixIcon: Icon(Icons.location_on, color: Colors.white70),
                ),
                onTap: () {
                  // TODO: Location Picker
                },
              ),
              const SizedBox(height: 16),
              _buildTimePicker(
                'Start Time',
                _selectedStartTime,
                (time) => setState(() => _selectedStartTime = time),
              ),
              const SizedBox(height: 16),
              _buildTimePicker(
                'End Time',
                _selectedEndTime,
                (time) => setState(() => _selectedEndTime = time),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => _saveItinerary(api, provider),
                  child: const Text('Save Activity', style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTimePicker(String label, DateTime time, Function(DateTime) onTimeSelected) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(time),
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
        if (picked != null) {
          final newTime = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            picked.hour,
            picked.minute,
          );
          onTimeSelected(newTime);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('h:mm a').format(time),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Icon(Icons.access_time, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Future<void> _saveItinerary(FirebaseTravelApi api, TravelPlanProvider provider) async {
    if (_formKey.currentState!.validate()) {
      try {
        final newItem = ItineraryItem(
          name: _nameController.text,
          startTime: _selectedStartTime,
          endTime: _selectedEndTime,
          location: _locationController.text,
          date: _selectedDate,
        );

        if (widget.existingItem != null) {
          await api.updateItinerary(
            widget.travelPlan.planId!,
            widget.existingItem!.id!,
            newItem.toJson(),
          );
        } else {
          await provider.addItineraryItem(widget.travelPlan.planId!, newItem);
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
