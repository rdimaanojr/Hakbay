import 'package:flutter/material.dart';
import 'package:hakbay/commons/constants.dart';
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
  bool _isPrivate = false;
  List<String> _selectedInterests = [];
  List<String> _selectedTravelStyles = [];

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _fnameController.text = widget.user!.fname;
      _lnameController.text = widget.user!.lname;
      _phoneController.text = widget.user!.phone;
      _selectedInterests = List.from(widget.user!.interests);
      _selectedTravelStyles = List.from(widget.user!.travelStyles);
      _isPrivate = widget.user!.isPrivate;
    }
  }

  @override
  void didUpdateWidget(EditProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user != oldWidget.user) {
      _updateFormFields();
    }
  }

  void _updateFormFields() {
    _fnameController.text = widget.user?.fname ?? '';
    _lnameController.text = widget.user?.lname ?? '';
    _phoneController.text = widget.user?.phone ?? '';
    _selectedInterests = List.from(widget.user?.interests ?? []);
    _selectedTravelStyles = List.from(widget.user?.travelStyles ?? []);
    _isPrivate = widget.user?.isPrivate ?? false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  void _toggleTravelStyle(String travelStyle) {
    setState(() {
      if (_selectedTravelStyles.contains(travelStyle)) {
        _selectedTravelStyles.remove(travelStyle);
      } else {
        _selectedTravelStyles.add(travelStyle);
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate() && widget.user != null) {
      try {
        final updatedUser = widget.user!.copyWith(
          fname: _fnameController.text,
          lname: _lnameController.text,
          phone: _phoneController.text,
          interests: _selectedInterests,
          travelStyles: _selectedTravelStyles,
          isPrivate: _isPrivate,
        );

        await Provider.of<UserProvider>(context, listen: false).updateUser(
          uid: updatedUser.uid!,
          fname: updatedUser.fname,
          lname: updatedUser.lname,
          phone: updatedUser.phone,
          interests: updatedUser.interests,
          travelStyles: updatedUser.travelStyles,
          isPrivate: updatedUser.isPrivate,
        );

        if (!mounted) return;
        Navigator.of(context).pop(updatedUser);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.toString()}')),
        );
      }
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
              const Text(
                "Select Interests",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Interests.all.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return GestureDetector(
                    onTap: () => _toggleInterest(interest),
                    child: Chip(
                      label: Text(
                        interest,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: isSelected
                            ? BorderSide(color: Theme.of(context).primaryColor, width: 1)
                            : const BorderSide(color: Colors.transparent),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              if (_selectedInterests.isNotEmpty) ...[
                const Text(
                  "Interests:",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedInterests.map((interest) => Chip(
                    label: Text(interest, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Theme.of(context).primaryColor,
                  )).toList(),
                ),
                const SizedBox(height: 24),
              ],
              const Text(
                "Select Travel Styles",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TravelStyles.all.map((travelStyle) {
                  final isSelected = _selectedTravelStyles.contains(travelStyle);
                  return GestureDetector(
                    onTap: () => _toggleTravelStyle(travelStyle),
                    child: Chip(
                      label: Text(
                        travelStyle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: isSelected
                            ? BorderSide(color: Theme.of(context).primaryColor, width: 1)
                            : const BorderSide(color: Colors.transparent),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              if (_selectedTravelStyles.isNotEmpty) ...[
                const Text(
                  "Travel Styles:",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTravelStyles.map((style) => Chip(
                    label: Text(style, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Theme.of(context).primaryColor,
                  )).toList(),
                ),
                const SizedBox(height: 24),
              ],
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
