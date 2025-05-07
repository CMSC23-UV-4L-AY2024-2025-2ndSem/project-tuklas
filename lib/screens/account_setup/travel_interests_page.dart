import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_profile_provider.dart';
import '../main_screen.dart';

class InterestsPage extends StatefulWidget {
  final String username;
  const InterestsPage({super.key, required this.username});

  @override
  State<InterestsPage> createState() => _InterestsState();
}

class _InterestsState extends State<InterestsPage> {
  final List<String> interests = [
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
    'Others'
  ];

  List<String> selectedInterests = [];

  @override
  void initState() {
    super.initState();
    _loadUserInterests();
  }

  // Load user interests when the page is initialized
  Future<void> _loadUserInterests() async {
    try {
      final profile = await context.read<UserProfileProvider>().fetchUserProfileOnce();
      setState(() {
        selectedInterests = List<String>.from(profile.interests ?? []);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load interests: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEDE1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          heading,
          selectInterests,
          SizedBox(height: 50),
          submitButton
        ],
      ),
    );
  }

  Widget get heading => Padding(
    padding: EdgeInsets.only(bottom: 0),
    child: Container(
      margin: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "Choose your Travel Interests",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 40,
              color: Color(0xFF027572),
            ),
          ),
        ],
      ),
    ),
  );

  Widget get selectInterests => Padding(
    padding: EdgeInsets.only(bottom: 5),
    child: Container(
      margin: EdgeInsets.all(10),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 2,
        children: interests.map((interestName) => interest(interestName)).toList(),
      ),
    ),
  );

  Widget interest(String title) {
    var isSelected = selectedInterests.contains(title);
    return OutlinedButton(
      onPressed: () {
        setState(() {
          if (isSelected) {
            selectedInterests.remove(title);
          } else {
            selectedInterests.add(title);
          }
        });
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Color(0xFF027572), width: 1),
        minimumSize: Size((title.length + 5).toDouble(), 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: isSelected ? Color(0xFF027572) : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : Color(0xFF027572),
        textStyle: GoogleFonts.poppins(fontSize: 16),
      ),
      child: Text(title),
    );
  }

  Widget get submitButton => ElevatedButton(
    onPressed: () async {
      // Save the selected interests to the user's profile
      try {
        await context.read<UserProfileProvider>().updateInterests(selectedInterests, widget.username);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interests updated successfully')),
        );

        // Navigate back to the main screen after saving
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving interests: $e')),
        );
      }
    },
    style: ElevatedButton.styleFrom(
      minimumSize: Size(350, 56),
      backgroundColor: Color(0xFFCA4A0C),
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    child: const Text("Continue", style: TextStyle(letterSpacing: 1)),
  );
}
