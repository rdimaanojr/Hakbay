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
  late TextEditingController _fnameController;
  late TextEditingController _lnameController;
  late TextEditingController _phoneController;
  bool _isPrivate = false;
  List<String> _selectedInterests = [];
  List<String> _selectedTravelStyles = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _fnameController = TextEditingController(text: widget.user?.fname ?? '');
    _lnameController = TextEditingController(text: widget.user?.lname ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _selectedInterests = List.from(widget.user?.interests ?? []);
    _selectedTravelStyles = List.from(widget.user?.travelStyles ?? []);
    _isPrivate = widget.user?.isPrivate ?? false;
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleSelection(String item, List<String> list) {
    setState(() {
      list.contains(item) ? list.remove(item) : list.add(item);
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || widget.user == null) return;

    setState(() => _isSaving = true);

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
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildTextInput(String label, TextEditingController controller, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white54),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.greenAccent),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: required
            ? (value) => value?.isEmpty ?? true ? '$label is required' : null
            : null,
      ),
    );
  }

  Widget _buildSelectionSection(String title, List<String> options, List<String> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((item) => FilterChip(
            label: Text(item),
            selected: selected.contains(item),
            selectedColor: Colors.green,
            backgroundColor: Colors.white24,
            labelStyle: TextStyle(
              color: selected.contains(item) ? Colors.white : Colors.white70,
            ),
            onSelected: (_) => _toggleSelection(item, selected),
          )).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2E1D), // Dark green background
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF1B5E20), // Dark green app bar
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextInput('First Name', _fnameController),
              _buildTextInput('Last Name', _lnameController),
              _buildTextInput('Phone Number', _phoneController, required: false),
              
              const SizedBox(height: 16),
              _buildSelectionSection('Your Interests', Interests.all, _selectedInterests),
              _buildSelectionSection('Travel Styles', TravelStyles.all, _selectedTravelStyles),
              
              SwitchListTile(
                title: const Text('Private Account', style: TextStyle(color: Colors.white)),
                value: _isPrivate,
                activeColor: Colors.greenAccent,
                inactiveTrackColor: Colors.white24,
                onChanged: (value) => setState(() => _isPrivate = value),
              ),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C), // Button green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'SAVE CHANGES',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
