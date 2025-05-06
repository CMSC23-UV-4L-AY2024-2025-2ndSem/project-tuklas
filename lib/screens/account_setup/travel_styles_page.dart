import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_profile_provider.dart';
import '../account_setup/travel_interests_page.dart';

class TravelStylesPage extends StatefulWidget {
  final String username;
  const TravelStylesPage({super.key, required this.username});

  @override
  State<TravelStylesPage> createState() => _TravelStylesState();
}

class _TravelStylesState extends State<TravelStylesPage> {
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
        'Others'
    ];
    List<String> selectedStyles = [];

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFDCEDE1),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  heading,
                  selectStyles,
                  SizedBox(height: 50),
                  submitButton
                ]
            )
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
              "Choose your Travel Styles",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Color(0xFF027572),
            )),
            Text(
            "This section is optional — you can skip it for now and add it later from your profile.",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0x80027572),
            )),
      ],
    ),
    ));

    Widget get selectStyles => Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Container(
        margin:EdgeInsets.all(10),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 2,
          children: travelStyles.map((styleName) => style(styleName)).toList()
        )
      )
    );

    Widget style(title){
      var isSelected = selectedStyles.contains(title);
      return OutlinedButton(
        onPressed: () {
          setState(() {
            if (isSelected){
              isSelected = false;
              selectedStyles.remove(title);
            } else {
              isSelected = true;
              selectedStyles.add(title);
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
        child: Text(title)
      );
    }

    Widget get submitButton => ElevatedButton(
      onPressed: () async {
        await context.read<UserProfileProvider>().profileService.editUserStyles(selectedStyles, widget.username);
        setState(() {
            // send selected values - selectedStyles to user db
            // Navigator.pushNamed(context, '/travel-interests', arguments: username);
            if (mounted) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => InterestsPage(username: widget.username)),
                );
            }
      });},
      style: ElevatedButton.styleFrom(
        minimumSize: Size(350, 56),
        backgroundColor: Color(0xFFCA4A0C),
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      child: const Text("Continue", style: TextStyle(letterSpacing: 1)),
    );
}