import 'package:flutter/material.dart';
import 'package:hakbay/models/user_model.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

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

      context.pop(updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final whiteTextStyle = const TextStyle(color: Colors.white);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Edit your profile information",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fnameController,
                style: whiteTextStyle,
                decoration: const InputDecoration(
                  labelText: "First Name",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
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
                style: whiteTextStyle,
                decoration: const InputDecoration(
                  labelText: "Last Name",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
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
                style: whiteTextStyle,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _interestsController,
                style: whiteTextStyle,
                decoration: const InputDecoration(
                  labelText: "Interests (comma-separated)",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _travelStylesController,
                style: whiteTextStyle,
                decoration: const InputDecoration(
                  labelText: "Travel Styles (comma-separated)",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.white,
                  switchTheme: SwitchThemeData(
                    thumbColor: MaterialStateProperty.all(Colors.white),
                    trackColor: MaterialStateProperty.all(Colors.white24),
                  ),
                ),
                child: SwitchListTile(
                  title: const Text("Private Account", style: TextStyle(color: Colors.white)),
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
