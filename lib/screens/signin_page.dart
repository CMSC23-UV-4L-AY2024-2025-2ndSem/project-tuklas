import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_TUKLAS/screens/signup_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? errorMessage;

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                title,
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                emailField,
                passwordField,
                submitButton,
                SizedBox(height: 10),
                signUpButton,
                SizedBox(height: 10),
                continueWGoogle,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get title => Padding(
    padding: EdgeInsets.all(30),
    child: Column(
      children: [
        Text(
          "TUKLAS",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 40,
            color: Color(0xFF027572),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Log in to your account",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0x80027572),
          ),
        ),
      ],
    ),
  );

  Widget get emailField => Padding(
    padding: const EdgeInsets.only(bottom: 20),
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
        label: const Text("Email address"),
        labelStyle: GoogleFonts.poppins(fontSize: 16, color: Color(0x80027572)),
        hintText: "Enter your email",
        hintStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: Color.fromARGB(128, 62, 82, 81),
        ),
      ),
      onSaved: (value) => setState(() => email = value),
      validator: (value) {
        if (value == null || value.isEmpty || !value.contains('@')) {
          return "Please enter a valid email";
        }
        return null;
      },
    ),
  );

  Widget get passwordField => Padding(
    padding: const EdgeInsets.only(bottom: 20),
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
        label: const Text("Password"),
        labelStyle: GoogleFonts.poppins(fontSize: 16, color: Color(0x80027572)),
        hintText: "Enter your password",
        hintStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: Color.fromARGB(128, 62, 82, 81),
        ),
      ),
      obscureText: true,
      onSaved: (value) => setState(() => password = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password can't be empty";
        }
        return null;
      },
    ),
  );

  Widget get submitButton => ElevatedButton(
    style: ElevatedButton.styleFrom(
      minimumSize: Size(350, 56),
      backgroundColor: Color(0xFFCA4A0C),
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    onPressed: () async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        //final provider = Provider.of<UserAuthProvider>(context, listen: false);
        //final error = await provider.signIn(email: email!, password: password!);

        // if (error != null) {
        //   setState(() => errorMessage = error);
        // } else if (mounted) {
        //   // Navigate to home screen
        //   Navigator.pushReplacementNamed(context, "/");
        // }
      }
    },
    child: Text(
      "Log in",
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget get signUpButton => TextButton(
    onPressed: () {
      //Navigator.pushNamed(context, '/signup');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignUpPage()),
      );
    },
    child: Text(
      "Don't have an account? ",
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: Color.fromARGB(128, 62, 82, 81),
      ),
    ),
  );

  Widget get continueWGoogle => ElevatedButton(
    style: ElevatedButton.styleFrom(
      minimumSize: Size(350, 56),
      backgroundColor: Color(0xFFA6D0C6),
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    onPressed: () {},
    child: Text(
      "Continue with Google",
      style: TextStyle(letterSpacing: 1, color: Color(0xFF027572)),
    ),
  );
}
