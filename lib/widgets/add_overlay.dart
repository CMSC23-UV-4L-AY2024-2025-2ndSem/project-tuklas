// add_overlay.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_TUKLAS/screens/addplan_page.dart';

typedef ActionCallback = void Function();

class AddOverlay extends StatelessWidget {
  final ActionCallback onClose;

  const AddOverlay({super.key, required this.onClose});

  void _onAddTravelBuddy() {
    // navigate here if context is passed
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      // fills the entire screen
      child: GestureDetector(
        // detects taps on the entire screen except for the buttons
        onTap: onClose,
        child: Container(
          color: Colors.black.withOpacity(0.25),
          child: Stack(
            children: [
              Positioned(
                bottom: 110, // positions just above the main nav bar
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      // travel plan button
                      onTap: () {
                        // Modified onTap directly
                        // 1. Close the overlay
                        onClose();
                        // 2. Navigate to AddtravelPage using the context from build method
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddtravelPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 130,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF027572),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Plan",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      // travel buddy button
                      onTap: _onAddTravelBuddy,
                      child: Container(
                        width: 130,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF027572),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.group_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Buddy",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
