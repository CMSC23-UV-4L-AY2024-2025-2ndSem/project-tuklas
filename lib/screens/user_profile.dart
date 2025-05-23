import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_TUKLAS/screens/account_setup/signup_page.dart';
import 'package:provider/provider.dart';
import 'package:project_TUKLAS/providers/user_profile_provider.dart';

class UserProfilePage extends StatefulWidget {
  final String username;
  const UserProfilePage({super.key, required this.username});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String username = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isPublic = true;
  File? imageFile;
  Uint8List? pickedFileBytes;
  List<String> selectedStyles = [];
  List<String> selectedInterests = [];
  bool _isLoading = true;
  bool _isEditing = false;

  final List<String> travelStyles = [
    'Adventure Travel', 'Luxury Travel', 'Leisure Travel', 'Budget Travel',
    'Business Travel', 'Culture Travel', 'Slow Travel', 'Eco Travel',
    'Solo Travel', 'Group Travel', 'Day Trip Travel', 'Others',
  ];

  final List<String> travelInterests = [
    'Beach', 'Mountain Hiking', 'Camping', 'Road Trips', 'Water Activities',
    'Safari/wildlife', 'Amusement Parks', 'Historical Landmarks',
    'Cultural Immersion', 'Night Life', 'Food Trips', 'Cafes', 'Others',
  ];

  @override
  void initState() {
    super.initState();
    username = widget.username;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserProfile());
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final profile = await context.read<UserProfileProvider>().fetchUserProfileOnce();
      if (!mounted) return; 
      setState(() {
        firstNameController.text = profile.firstName;
        lastNameController.text = profile.lastName;
        phoneController.text = profile.phoneNumber ?? '';
        selectedStyles = List.from(profile.styles ?? []);
        selectedInterests = List.from(profile.interests ?? []);
        username = profile.username;
        isPublic = profile.isPublic ?? true;
        if (profile.imageBase64?.isNotEmpty ?? false) {
          pickedFileBytes = base64Decode(profile.imageBase64!);
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      print('Form is not valid!');
      return;
    }

    final base64Image = pickedFileBytes != null ? base64Encode(pickedFileBytes!) : null;

    try {
      final userProfileProvider = context.read<UserProfileProvider>();
      final currentProfile = await userProfileProvider.fetchUserProfileOnce();

      if (currentProfile == null) {
        throw Exception('User profile not found');
      }

      await userProfileProvider.firebaseService.updateUserProfile(
        username: currentProfile.username,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        isPublic: isPublic,
        styles: selectedStyles,
        interests: selectedInterests,
      );

      if (base64Image != null) {
        bool success = await userProfileProvider.updateProfileImage(base64Image, currentProfile.username);

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile image')),
          );
          return;
        }
      }

      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      await _loadUserProfile();

    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving profile')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();

      setState(() {
        imageFile = File(pickedFile.path);
        pickedFileBytes = bytes;
      });
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF027572)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Profile', style: GoogleFonts.poppins(color: Color(0xFF027572), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF027572)),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SignUpPage()),
                  (_) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error logging out')),
                );
              }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF027572)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _isEditing ? _pickImage : null,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(0xFF69B3AE),
                            child: ClipOval(
                              child: pickedFileBytes != null
                                  ? Image.memory(pickedFileBytes!, width: 80, height: 80, fit: BoxFit.cover)
                                  : const Icon(Icons.person, size: 40, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(isPublic ? Icons.public : Icons.lock, size: 20, color: Colors.grey),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF027572),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => setState(() => _isEditing = !_isEditing),
                          child: Text(
                            _isEditing ? 'Cancel' : 'Edit Profile',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isEditing) ...[
                      _buildEditableField(firstNameController, 'First Name'),
                      _buildEditableField(lastNameController, 'Last Name'),
                      _buildEditableField(phoneController, 'Phone Number'),
                      SwitchListTile(
                        title: const Text('Public Profile'),
                        value: isPublic,
                        onChanged: (val) => setState(() => isPublic = val),
                      ),
                    ] else ...[
                      Text('${firstNameController.text} ${lastNameController.text}', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(username, style: GoogleFonts.poppins(color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(phoneController.text, style: GoogleFonts.poppins(color: Colors.black54)),
                    ],
                    const Divider(height: 32),
                    Text('Travel Styles', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildChipSelector(travelStyles, selectedStyles, _isEditing),
                    const SizedBox(height: 16),
                    Text('Travel Interests', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildChipSelector(travelInterests, selectedInterests, _isEditing),
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF027572), // Background color
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(color: Colors.white), // Text color set to white
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEditableField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF027572), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) => value!.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildChipSelector(List<String> options, List<String> selected, bool isEditable) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final selectedFlag = selected.contains(option);
        return ChoiceChip(
          label: Text(option, style: GoogleFonts.poppins(color: selectedFlag ? Colors.white : Colors.black)),
          selected: selectedFlag,
          onSelected: isEditable
              ? (_) => setState(() {
                    selectedFlag ? selected.remove(option) : selected.add(option);
                  })
              : null,
          selectedColor: Color(0xFF027572),
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      }).toList(),
    );
  }
}