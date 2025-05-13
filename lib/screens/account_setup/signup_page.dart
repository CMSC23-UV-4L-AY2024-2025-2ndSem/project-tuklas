import 'package:flutter/material.dart';
import 'package:project_TUKLAS/screens/account_setup/travel_styles_page.dart';
import 'package:project_TUKLAS/screens/signin_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/signup_form_values.dart';

// The SignUp page ask for the users email and password,
// Email must be in proper format and can be used multiple times.
// Passwords will be checked if it is at least 6 characters,
// contains an uppercase and lowercase letter, a number, and at least one special character.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool showEmailSignUpErrorMessage = false;

  List<String> special = [
    '!',
    '.',
    '@',
    '#',
    '&',
    '\$',
    '_',
    '/',
  ]; // allowed special characters ?
  FormValues formValues = FormValues();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEDE1),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: 100),
                heading, // app title
                Container(
                  // input field container
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      nameField('Email', 'email'),
                      nameField('Password', 'password'),
                    ],
                  ),
                ),
                // error messages - not always displayed
                showEmailSignUpErrorMessage
                    ? signUpErrorMessage('Email')
                    : Container(),

                Container(
                  // button container
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      submitButton,
                      signInButton,
                      Divider(
                        color: Color(0xFF027572),
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      SizedBox(height: 20),
                      signUpWithGoogle,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get heading => Padding(
    padding: EdgeInsets.only(bottom: 10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          "TUKLAS",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 40,
            color: Color(0xFF027572),
          ),
        ),
        Text(
          "Create a new account",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0x80027572),
          ),
        ),
      ],
    ),
  );

  Widget nameField(label, val) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF027572)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF027572), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        label: Text(label),
        labelStyle: GoogleFonts.poppins(fontSize: 16, color: Color(0x80027572)),
        hintText: "Enter your ${label.toLowerCase()}",
        hintStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: Color.fromARGB(128, 62, 82, 81),
        ),
      ),
      obscureText: (val == 'password') ? true : false,
      onSaved:
          (value) => setState(() => formValues.textfieldValues[val] = value),
      validator: (value) {
        // validate email and password
        int upCheck = 0; // checkers for each password requirement
        int lowCheck = 0;
        int numCheck = 0;
        int sCheck = 0;
        if (value == null || value.isEmpty) {
          return "Please enter your ${label.toLowerCase()}";
        }
        // if input field is for email address,
        if (val == 'email' && (!value.contains('@') || !value.contains('.'))) {
          // check for significant symbols
          return "Please enter a valid email format";
        } // if input field is for password
        else if (val == 'password') {
          if (value.length < 6) {
            return "Password must be at least 6 characters.";
          } else {
            for (int i = 0; i < value.length; i++) {
              if (special.contains(value[i])) {
                // special character check
                sCheck = 1;
                continue;
              } else if (int.tryParse(value[i]).runtimeType == int) {
                // number check
                numCheck = 1;
                continue;
              } else if (value[i].codeUnitAt(0) >= 65 &&
                  value[i].codeUnitAt(0) <= 90) {
                // uppercase letter check
                upCheck = 1;
                continue;
              } else if (value[i].codeUnitAt(0) >= 97 &&
                  value[i].codeUnitAt(0) <= 122) {
                // lowercase letter check
                lowCheck = 1;
                continue;
              }
            }
            if (upCheck == 0 || lowCheck == 0 || sCheck == 0 || numCheck == 0) {
              // if any checker is not equal to 1, do not accept password
              return "Please enter a valid password! At least 6 characters, \ncontains an uppercase and lowercase letter, a number, \nand at least one special character.";
            } else {
              return null;
            }
          }
        }
        return null;
      },
      style: TextStyle(color: Color(0xFF027572)),
    ),
  );

  Widget signUpErrorMessage(cred) => Padding(
    // will be displayed when either email is already being used by existing account
    padding: EdgeInsets.only(bottom: 10),
    child: Text(
      "$cred already in use!",
      style: GoogleFonts.poppins(fontSize: 13, color: Colors.red),
    ),
  );

  Widget get submitButton => ElevatedButton(
    onPressed: () async {
      if (_formKey.currentState!.validate()) {
        // email and password validated
        _formKey.currentState!.save();
        // navigate to TravelStylePage
        Navigator.pop(context);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TravelStylesPage(
                    email: formValues.textfieldValues['email']!,
                    password: formValues.textfieldValues['password']!,
                  ),
            ),
          );
        }
      }
    },
    style: ElevatedButton.styleFrom(
      minimumSize: Size(350, 56),
      backgroundColor: Color(0xFFCA4A0C),
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    child: const Text("Sign Up", style: TextStyle(letterSpacing: 1)),
  );

  Widget get signInButton => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Color.fromARGB(128, 62, 82, 81),
          ),
        ),
        TextButton(
          onPressed: () {
            // Move to sign in page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignInPage()),
            );
          },
          child: Text(
            "Sign In",
            style: GoogleFonts.poppins(fontSize: 15, color: Color(0xFFCA4A0C)),
          ),
        ),
      ],
    ),
  );

  Widget get signUpWithGoogle => ElevatedButton(
    // NOT YET IMPLEMENTED PROPERLY !!!!!!
    // Works as normal sign up button
    onPressed: () async {
      String? message;
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        // bool userExists = await context
        //     .read<UserAuthProvider>()
        //     .authService
        //     .checkUsername(formValues.textfieldValues['uName']!);

        // if (userExists) {
        //   // if it is not empty, username is already being used
        //   showUserSignUpErrorMessage = true;
        // } else {
        //   showUserSignUpErrorMessage = false;
        // }

        setState(() {
          if (message == "Success!") {
            // navigate to mian screen
            showEmailSignUpErrorMessage = false;
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TravelStylesPage(
                        email: formValues.textfieldValues['email']!,
                        password: formValues.textfieldValues['password']!,
                      ),
                ),
              );
            }
          } else {
            if (message == 'email-already-in-use') {
              showEmailSignUpErrorMessage = true;
            }
          }
        });
      }
    },
    style: ElevatedButton.styleFrom(
      minimumSize: Size(350, 56),
      backgroundColor: Color(0xFFA6D0C6),
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    child: const Text(
      "Sign Up With Google",
      style: TextStyle(letterSpacing: 1, color: Color(0xFF027572)),
    ),
  );
}
