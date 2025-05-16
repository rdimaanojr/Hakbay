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
  DateTime _selectedStartTime = DateTime.now();
  DateTime _selectedEndTime = DateTime.now();
  int _selectedDay = 1;

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      _nameController.text = widget.existingItem!.name;
      _selectedStartTime = widget.existingItem!.startTime;
      _selectedEndTime = widget.existingItem!.endTime;
      _selectedDay = widget.existingItem!.day ?? 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<FirebaseTravelApi>(context);
    final provider = Provider.of<TravelPlanProvider>(context, listen: false);
    final totalDays = widget.travelPlan.travelDate.duration.inDays + 1;

    return Scaffold(
      backgroundColor: Colors.grey[900],
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
              _buildDayDropdown(totalDays),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Activity Name*',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Location',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.location_on, color: Colors.white70),
                ),
                onTap: () {
                  // TODO: Implement location picker
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
                  onPressed: () => _saveItinerary(api, provider),
                  child: const Text('Save Activity'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayDropdown(int totalDays) {
    return DropdownButtonFormField<int>(
      value: _selectedDay,
      decoration: const InputDecoration(
        labelText: 'Day',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(),
      ),
      items: List.generate(totalDays, (index) {
        final day = index + 1;
        final date = widget.travelPlan.travelDate.start.add(Duration(days: index));
        return DropdownMenuItem<int>(
          value: day,
          child: Text(
            'Day $day (${DateFormat('MMM d').format(date)})',
            style: const TextStyle(color: Colors.white),
          ),
        );
      }),
      onChanged: (value) => setState(() => _selectedDay = value!),
    );
  }

  Widget _buildTimePicker(String label, DateTime time, Function(DateTime) onTimeSelected) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(time),
        );
        if (picked != null) {
          final newTime = DateTime(
            time.year,
            time.month,
            time.day,
            picked.hour,
            picked.minute,
          );
          onTimeSelected(newTime);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(),
        ),
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
          day: _selectedDay,
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