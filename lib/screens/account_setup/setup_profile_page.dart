import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_TUKLAS/models/signup_form_values.dart';
import 'package:project_TUKLAS/providers/auth_provider.dart';
import 'package:project_TUKLAS/screens/main_screen.dart';
import 'dart:io';
import "package:image_picker/image_picker.dart"; //to pick an image
import 'package:flutter/foundation.dart'
    show kIsWeb; // bool to check if app runs on mobile or web
import 'package:provider/provider.dart';

class SetupProfilePage extends StatefulWidget {
  final String? email, password; // must accept an email
  final List<String>? travelStyles, travelInterests;
  const SetupProfilePage({
    super.key,
    required this.email,
    this.travelStyles,
    this.travelInterests,
    required this.password,
  });

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  File? image; // to render image on mobile
  Uint8List? pickedFileBytes; //to render image on web

  bool showUserSignUpErrorMessage = false;
  FormValues formValues = FormValues();

  // method to pick image from storage
  Future<void> _pickImage() async {
    try {
      // if the platform is web
      if (kIsWeb) {
        final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            pickedFileBytes = bytes;
          });
          print("Successfully picked image for web...");
        }
      } else {
        // if platform is mobile
        final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );

        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            image = File(pickedFile.path);
            pickedFileBytes = bytes;
          });
          print("Successfully picked image for mobile...");
        }
      }
    } catch (e) {
      print("Error picking image: $e");
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
      if (!kIsWeb && image != null) {
        print("Rendering image for mobile");
        // render for mobile
        return ClipOval(
          child: Image.file(image!, width: 140, height: 140, fit: BoxFit.cover),
        );
      } else if (kIsWeb && pickedFileBytes != null) {
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
    onSaved:
        (value) => setState(
          () => formValues.textfieldValues['fName'] = firstNameController.text,
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
    onSaved:
        (value) => setState(
          () => formValues.textfieldValues['lName'] = lastNameController.text,
        ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return "Last name is required";
      }
      return null;
    },
  );

  Widget get userNamefield => TextFormField(
    controller: userNameController,
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
    onSaved:
        (value) => setState(
          () => formValues.textfieldValues['uName'] = userNameController.text,
        ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Username is required';
      } else {
        // check if username format is valid
        for (int i = 0; i < value.length; i++) {
          if ((int.tryParse(value[i]).runtimeType ==
                  int) || // check if character is a number
              (value[i] == '.' ||
                  value[i] == '_') || // check if character is a '.' or '_'
              value[i].codeUnitAt(0) >= 65 &&
                  value[i].codeUnitAt(0) <=
                      90 || // check if character is an uppercase letter
              value[i].codeUnitAt(0) >= 97 && value[i].codeUnitAt(0) <= 122) {
            // check if character is a lowercase letter
            continue;
          } else {
            return "A username may only contain letters A-Z or a-z, 0-9, _ and .";
          }
        }
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
        String? message;
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          //check if username exist
          bool userExists = await context
              .read<UserAuthProvider>()
              .authService
              .checkUsername(formValues.textfieldValues['uName']!);
          if (userExists) {
            showUserSignUpErrorMessage = true; //show error message
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Username already exists.')));
            userNameController.clear();
          } else {
            // SIGN UP USER CREDENTIALS
            if (mounted) {
              print("Signing up using email: ${widget.email}");
              message = await context
                  .read<UserAuthProvider>()
                  .authService
                  .signUp(
                    widget.email!,
                    widget.password!,
                    formValues.textfieldValues['fName']!,
                    formValues.textfieldValues['lName']!,
                    formValues.textfieldValues['uName']!,
                    widget.travelStyles!,
                    widget.travelInterests!,
                  );

              // IF NO ERRORS, NAVIGATE TO MAIN SCREEN
              if (message == "Success!") {
                // navigate to main screen
                showUserSignUpErrorMessage = false;
                // SAVE IMAGE TO FIREBASE STORAGE
                String username = formValues.textfieldValues['uName']!;
                if (image != null || pickedFileBytes != null) {
                  try {
                    // reference: https://firebase.flutter.dev/docs/storage/upload-files
                    if (kIsWeb) {
                      // if platform is web
                      await context.read<UserAuthProvider>().uploadUserImage(
                        pickedFileBytes,
                        username,
                      );
                    } else {
                      // if platform is mobile/desktop
                      await context.read<UserAuthProvider>().uploadUserImage(
                        image,
                        username,
                      );
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image uploaded successfully!'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error uploading image: $e')),
                    );
                  }
                }
                // navigate to main screen after setting up profile
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              } else {
                //display error
                showUserSignUpErrorMessage = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sign-up error: $message')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error signing up user: not mounted')),
              );
            }
          }
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

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    userNameController.dispose();
    super.dispose();
  }
}
