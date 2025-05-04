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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();
  final TextEditingController _travelStylesController = TextEditingController();
  bool _isPrivate = false;

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

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _phoneController.dispose();
    _interestsController.dispose();
    _travelStylesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Edit your profile information", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              TextFormField(
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
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _interestsController,
                decoration: const InputDecoration(labelText: "Interests (comma-separated)"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _travelStylesController,
                decoration: const InputDecoration(labelText: "Travel Styles (comma-separated)"),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Provider.of<UserProvider>(context, listen: false).updateUser(
                      widget.user!.uid ?? '',
                      _fnameController.text,
                      _lnameController.text,
                      _phoneController.text,
                      _interestsController.text.split(',').map((e) => e.trim()).toList(),
                      _travelStylesController.text.split(',').map((e) => e.trim()).toList(),
                      _isPrivate,
                    );
                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
