import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_TUKLAS/models/signup_form_values.dart';
import 'package:project_TUKLAS/providers/user_profile_provider.dart';
import 'package:project_TUKLAS/screens/main_screen.dart';
import "package:image_picker/image_picker.dart"; //to pick an image
import 'package:provider/provider.dart';

class SetupProfilePage extends StatefulWidget {
  final String? username;
  const SetupProfilePage({super.key, required this.username});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  XFile? image;
  Uint8List? pickedFileBytes;
  FormValues formValues = FormValues();

  // method to pick image from storage
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          image = pickedFile;
          pickedFileBytes = bytes;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    formValues.textfieldValues['uName'] = widget.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEDE1),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Row(children: [backButton]),
                SizedBox(height: 50),
                heading,
                SizedBox(height: 30),
                avatar,
                SizedBox(height: 10),
                firstNamefield,
                SizedBox(height: 5),
                lastNamefield,
                SizedBox(height: 40),
                continueButton,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get heading => Text(
    "Set up your profile",
    style: GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      fontSize: 40,
      color: Color(0xFF027572),
    ),
  );

  Widget get avatar => Stack(
    alignment: Alignment.bottomRight,
    children: [
      CircleAvatar(
        radius: 70,
        backgroundColor: Color(0xFF69B3AE),
        child: updateAvatar(),
      ),
      Positioned(
        child: GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF00796B),
            child: Icon(Icons.edit, color: Colors.white, size: 16),
          ),
        ),
      ),
    ],
  );

  Widget updateAvatar() {
    try {
      return ClipOval(
        child:
            image != null
                ? Image.file(
                  File(image!.path),
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                )
                : const Icon(Icons.person, size: 50, color: Colors.white),
      );
    } catch (e) {
      print("Error rendering image on $e");
      return Icon(Icons.error, color: Colors.red);
    }
  }

  Widget get firstNamefield => TextFormField(
    controller: firstNameController,
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF027572)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF027572), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      label: Text("First Name"),
      labelStyle: GoogleFonts.poppins(fontSize: 16, color: Color(0x80027572)),
      hintText: "Enter your first name",
      hintStyle: GoogleFonts.poppins(
        fontSize: 16,
        color: Color.fromARGB(128, 62, 82, 81),
      ),
    ),
    onSaved: (value) {
      formValues.textfieldValues['fName'] = firstNameController.text;
    },
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return "First name is required";
      }
      return null;
    },
  );

  Widget get lastNamefield => TextFormField(
    controller: lastNameController,
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF027572)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF027572), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      label: Text("Last Name"),
      labelStyle: GoogleFonts.poppins(fontSize: 16, color: Color(0x80027572)),
      hintText: "Enter your last name",
      hintStyle: GoogleFonts.poppins(
        fontSize: 16,
        color: Color.fromARGB(128, 62, 82, 81),
      ),
    ),
    onSaved: (value) {
      formValues.textfieldValues['lName'] = lastNameController.text;
    },
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return "Last name is required";
      }
      return null;
    },
  );

  Widget get continueButton => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(350, 56),
        backgroundColor: Color(0xFFCA4A0C),
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onPressed: () async {
        // SAVE DATA TO FIRESTORE
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          await context.read<UserProfileProvider>().addName(
            formValues.textfieldValues['uName']!,
            formValues.textfieldValues['fName']!,
            formValues.textfieldValues['lName']!,
          );

          //upload image to Firestore as base64
          final base64Image =
              pickedFileBytes != null ? base64Encode(pickedFileBytes!) : null;

          if (base64Image != null) {
            // get username from the current user profile in provider
            final username =
                context
                    .read<UserProfileProvider>()
                    .currentUserProfile
                    ?.username;

            if (username != null && username.isNotEmpty) {
              await context.read<UserProfileProvider>().updateProfileImage(
                base64Image,
                username,
              );
            } else {
              // handle missing username case (e.g., show error)
            }
          }

          //display success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile created successfully.')),
          );

          // navigate to main screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        }
      },
      child: const Text("Continue", style: TextStyle(letterSpacing: 1)),
    ),
  );

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
}
