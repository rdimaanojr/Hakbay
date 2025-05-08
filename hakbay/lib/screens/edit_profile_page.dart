import 'package:flutter/material.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final AppUser? user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  // TextEditingControllers for each field
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();
  final TextEditingController _travelStylesController = TextEditingController();
  bool _isPrivate = false;

  // Initialize the form with existing user data if available
  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _fnameController.text = widget.user!.fname;
      _lnameController.text = widget.user!.lname;
      _phoneController.text = widget.user!.phone;
      _interestsController.text = widget.user!.interests.join(', ');
      _travelStylesController.text = widget.user!.travelStyles.join(', ');
      _isPrivate = widget.user!.isPrivate;
    }
  }

  // Dispose of the controllers to free up resources
  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _phoneController.dispose();
    _interestsController.dispose();
    _travelStylesController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedUser = widget.user!.copyWith(
        fname: _fnameController.text,
        lname: _lnameController.text,
        phone: _phoneController.text,
        interests:
            _interestsController.text.split(',').map((e) => e.trim()).toList(),
        travelStyles:
            _travelStylesController.text
                .split(',')
                .map((e) => e.trim())
                .toList(),
        isPrivate: _isPrivate,
      );

      Provider.of<UserProvider>(context, listen: false).updateUser(
        uid: updatedUser.uid!,
        fname: updatedUser.fname,
        lname: updatedUser.lname,
        phone: updatedUser.phone,
        interests: updatedUser.interests,
        travelStyles: updatedUser.travelStyles,
        isPrivate: updatedUser.isPrivate,
      );

      Navigator.pop(context, updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Edit your profile information",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextFormField(
                // Text field for first name
                controller: _fnameController,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your first name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                // Text field for last name
                controller: _lnameController,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your last name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                // Text field for phone number
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                // Text field for interests
                controller: _interestsController,
                decoration: const InputDecoration(
                  labelText: "Interests (comma-separated)",
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                // Text field for travel styles
                controller: _travelStylesController,
                decoration: const InputDecoration(
                  labelText: "Travel Styles (comma-separated)",
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                // Switch for private account option
                title: const Text("Private Account"),
                value: _isPrivate,
                onChanged: (value) {
                  setState(() {
                    _isPrivate = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                // Button to save changes
                onPressed: _saveChanges,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
