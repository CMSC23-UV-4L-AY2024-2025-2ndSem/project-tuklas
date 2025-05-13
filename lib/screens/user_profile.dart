import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:project_TUKLAS/providers/user_profile_provider.dart';
import 'main_screen.dart';

class UserProfilePage extends StatefulWidget {
  final String username;
  const UserProfilePage({super.key, required this.username});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  File? imageFile;
  Uint8List? pickedFileBytes;
  List<String> selectedStyles = [];
  List<String> selectedInterests = [];

  final List<String> travelStyles = [
    'Adventure Travel',
    'Luxury Travel',
    'Leisure Travel',
    'Budget Travel',
    'Business Travel',
    'Culture Travel',
    'Slow Travel',
    'Eco Travel',
    'Solo Travel',
    'Group Travel',
    'Day Trip Travel',
    'Others',
  ];

  final List<String> travelInterests = [
    'Beach',
    'Mountain Hiking',
    'Camping',
    'Road Trips',
    'Water Activities',
    'Safari/wildlife',
    'Amusement Parks',
    'Historical Landmarks',
    'Cultural Immersion',
    'Night Life',
    'Food Trips',
    'Cafes',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile =
          await context.read<UserProfileProvider>().fetchUserProfileOnce();

      if (!mounted) return;

      setState(() {
        nameController.text = profile.name;
        usernameController.text = profile.username;
        selectedStyles = List<String>.from(profile.styles ?? []);
        selectedInterests = List<String>.from(profile.interests ?? []);
        if (profile.imageBase64 != null && profile.imageBase64!.isNotEmpty) {
          pickedFileBytes = base64Decode(profile.imageBase64!);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final newUsername = usernameController.text.trim();
      final newName = nameController.text.trim();
      final base64Image =
          pickedFileBytes != null ? base64Encode(pickedFileBytes!) : null;

      try {
        // update the profile with the new data
        await context
            .read<UserProfileProvider>()
            .firebaseService
            .updateUserProfile(
              username: newUsername,
              name: newName,
              styles: selectedStyles,
              interests: selectedInterests,
              imageBase64: base64Image,
            );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        imageFile = File(pickedFile.path);
        pickedFileBytes = bytes;
      });
    }
  }

  Widget _buildTopBar() {
    return AppBar(
      backgroundColor: const Color(0xFFDCEDE1),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Color(0xFF027572),
        ),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (Route<dynamic> route) => false,
          );
        },
      ),
      title: Text(
        'Profile',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: const Color(0xFF027572),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF027572)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: const Color(0xFF69B3AE),
          child: ClipOval(
            child:
                pickedFileBytes != null
                    ? Image.memory(
                      pickedFileBytes!,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    )
                    : const Icon(Icons.person, size: 50, color: Colors.white),
          ),
        ),
        Positioned(
          child: GestureDetector(
            onTap: _pickImage,
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF00796B),
              child: Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF027572)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF027572), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color(0x80027572),
        ),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color.fromARGB(128, 62, 82, 81),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildSelectableChips({
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              selectedColor: const Color(0xFF027572),
              backgroundColor: Colors.transparent,
              labelStyle: GoogleFonts.poppins(
                color: isSelected ? Colors.white : const Color(0xFF027572),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF027572)),
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEDE1),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _buildTopBar(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatar(),
              const SizedBox(height: 20),
              _buildTextField(
                controller: nameController,
                label: 'Name',
                hint: 'Enter your name',
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: usernameController,
                label: 'Username',
                hint: 'Enter your username',
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Travel Styles',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFF027572),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildSelectableChips(
                options: travelStyles,
                selectedOptions: selectedStyles,
                onSelected: (style) {
                  setState(() {
                    if (selectedStyles.contains(style)) {
                      selectedStyles.remove(style);
                    } else {
                      selectedStyles.add(style);
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Travel Interests',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFF027572),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildSelectableChips(
                options: travelInterests,
                selectedOptions: selectedInterests,
                onSelected: (interest) {
                  setState(() {
                    if (selectedInterests.contains(interest)) {
                      selectedInterests.remove(interest);
                    } else {
                      selectedInterests.add(interest);
                    }
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: const Color(0xFF027572),
                ),
                child: Text(
                  'Save Profile',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
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
