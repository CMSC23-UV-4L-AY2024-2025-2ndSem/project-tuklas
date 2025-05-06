import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_TUKLAS/models/signup_form_values.dart';
import 'package:project_TUKLAS/providers/auth_provider.dart';
import 'package:project_TUKLAS/screens/main_screen.dart';
import 'dart:io';
import "package:image_picker/image_picker.dart"; //to pick an image
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

class SetupProfilePage extends StatefulWidget {
  final String email; // must accept an email
  const SetupProfilePage({super.key, required this.email});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  File? imageFile;
  Uint8List? pickedFileBytes; //to render image on web

  bool showUserSignUpErrorMessage = false;
  FormValues formValues = FormValues();

  // method to pick image from storage
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); // Await outside setState
      setState(() {
        imageFile = File(pickedFile.path); // For mobile
        pickedFileBytes = bytes; // For web
      });
      print("Successfully picked image...");
    }
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
                SizedBox(height: 5),
                userNamefield,
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
      if (!kIsWeb && imageFile != null) {
        print("Rendering image for mobile");
        // render for mobile
        return ClipOval(
          child: Image.file(
            imageFile!,
            width: 140,
            height: 140,
            fit: BoxFit.cover,
          ),
        );
      } else if (pickedFileBytes != null) {
        print("Rendering image for web");
        //render for web
        return ClipOval(
          child: Image.memory(
            pickedFileBytes!,
            width: 140,
            height: 140,
            fit: BoxFit.cover,
          ),
        );
      } else {
        print("No image picked...");
        // render if no image picked
        return Icon(Icons.person, size: 50, color: Colors.white);
      }
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
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return "Last name is required";
      }
      return null;
    },
  );

  Widget get userNamefield => TextFormField(
    controller: usernameController,
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF027572)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF027572), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      label: Text("Username"),
      labelStyle: GoogleFonts.poppins(fontSize: 16, color: Color(0x80027572)),
      hintText: "Enter your username",
      hintStyle: GoogleFonts.poppins(
        fontSize: 16,
        color: Color.fromARGB(128, 62, 82, 81),
      ),
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Username is required';
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
        String? message, base64Image;
        if (pickedFileBytes != null) {
          base64Image = base64Encode(
            pickedFileBytes!,
          ); // encode as String when saving
        }
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          //check if username exist
          bool userExists = await context
              .read<UserAuthProvider>()
              .authService
              .checkUsername(formValues.textfieldValues['uName']!);
          if (userExists) {
            //show error message
            showUserSignUpErrorMessage = true;
          } else {
            message = await context.read<UserAuthProvider>().authService.signUp(
              formValues.textfieldValues['email']!,
              formValues.textfieldValues['password']!,
              formValues.textfieldValues['fName']!,
              formValues.textfieldValues['lName']!,
              formValues.textfieldValues['uName']!,
              base64Image,
            );
          }
          // IF NO ERRORS, NAVIGATE TO MAIN SCREEN
          setState(() {
            if (message == "Success!") {
              // navigate to main screen
              showUserSignUpErrorMessage = false;
              // Move to homepage ! all checks completed, sign up success
              Navigator.pop(context);
              if (mounted) {
                // navigate to main screen after setting up profile
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              }
            } else {
              if (message == 'email-already-in-use') {
                showUserSignUpErrorMessage = true;
              }
            }
          });
        }
      },
      child: const Text("Continue", style: TextStyle(letterSpacing: 1)),
    ),
  );

  // OPTIONAL WIDGET
  // this gives the user the option to return to previous page
  Widget get backButton => IconButton(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: Icon(Icons.arrow_back_ios_rounded),
  );
}
