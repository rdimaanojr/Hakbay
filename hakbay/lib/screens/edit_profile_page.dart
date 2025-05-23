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
    _updateFormFields();
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
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final whiteTextStyle = theme.textTheme.bodyLarge?.copyWith(color: Colors.white);
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    final subtitleStyle = theme.textTheme.titleMedium?.copyWith(
      color: Colors.white70,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit your profile",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Update your personal information and preferences",
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              
              // Personal Information Section
              _buildSectionHeader("Personal Information", theme),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _fnameController,
                label: "First Name",
                validator: (value) => value?.isEmpty ?? true ? "Please enter your first name" : null,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _lnameController,
                label: "Last Name",
                validator: (value) => value?.isEmpty ?? true ? "Please enter your last name" : null,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _phoneController,
                label: "Phone Number",
                keyboardType: TextInputType.phone,
                theme: theme,
              ),
              const SizedBox(height: 32),
              
              // Interests Section
              _buildSectionHeader("Your Interests", theme),
              const SizedBox(height: 8),
              Text(
                "Select your interests to help us match you with like-minded travelers",
                style: subtitleStyle,
              ),
              const SizedBox(height: 16),
              _buildChipSelection(
                items: Interests.all,
                selectedItems: _selectedInterests,
                onTap: _toggleInterest,
                theme: theme,
              ),
              if (_selectedInterests.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSelectedItemsPreview(
                  title: "Selected Interests",
                  items: _selectedInterests,
                  theme: theme,
                ),
              ],
              const SizedBox(height: 32),
              
              // Travel Styles Section
              _buildSectionHeader("Travel Styles", theme),
              const SizedBox(height: 8),
              Text(
                "Select your preferred travel styles",
                style: subtitleStyle,
              ),
              const SizedBox(height: 16),
              _buildChipSelection(
                items: TravelStyles.all,
                selectedItems: _selectedTravelStyles,
                onTap: _toggleTravelStyle,
                theme: theme,
              ),
              if (_selectedTravelStyles.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSelectedItemsPreview(
                  title: "Selected Travel Styles",
                  items: _selectedTravelStyles,
                  theme: theme,
                ),
              ],
              const SizedBox(height: 32),
              
              // Privacy Section
              _buildSectionHeader("Privacy Settings", theme),
              const SizedBox(height: 16),
              _buildPrivacySwitch(theme),
              const SizedBox(height: 40),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "SAVE CHANGES",
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    required ThemeData theme,
  }) {
    return TextFormField(
      controller: controller,
      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Widget _buildChipSelection({
    required List<String> items,
    required List<String> selectedItems,
    required Function(String) onTap,
    required ThemeData theme,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        return ChoiceChip(
          label: Text(item),
          selected: isSelected,
          onSelected: (selected) => onTap(item),
          selectedColor: theme.primaryColor,
          backgroundColor: theme.cardColor,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? theme.primaryColor : Colors.transparent,
              width: 1,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedItemsPreview({
    required String title,
    required List<String> items,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Chip(
            label: Text(item),
            backgroundColor: theme.primaryColor.withOpacity(0.2),
            labelStyle: theme.textTheme.bodySmall?.copyWith(color: const Color.fromARGB(255, 22, 65, 24)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.primaryColor),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPrivacySwitch(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: SwitchListTile(
        title: Text(
          "Private Account",
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
        ),
        subtitle: Text(
          "When enabled, your profile will not be visible to other users",
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
        ),
        value: _isPrivate,
        activeColor: theme.primaryColor,
        inactiveTrackColor: Colors.white24,
        contentPadding: EdgeInsets.zero,
        onChanged: (value) => setState(() => _isPrivate = value),
      ),
    );
  }
}