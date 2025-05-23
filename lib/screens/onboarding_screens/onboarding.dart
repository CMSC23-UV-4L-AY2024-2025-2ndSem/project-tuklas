import 'package:flutter/material.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  // Helper function for indicator dots
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 6.0),
      height: 8.0,
      width: _currentPage == index ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color:
            _currentPage == index
                ? Color(0xFFCA4A0C)
                : Color.fromARGB(150, 202, 75, 12),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              // --- First Onboarding Screen ---
              Container(
                color: Color(0xFFDCEEE2), // Change background color
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TODO: Add the image/illustration for the first screen here
                    // Example: Image.asset('assets/images/illustration1.png'),
                    SizedBox(height: 50),
                    // TODO: Add the title for the first screen here (e.g., "WEBSITES & APPS")
                    // Example: Text("WEBSITES & APPS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 20),
                    // TODO: Add the description text for the first screen here
                    // Example: Text("We'll build and maintain...", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
                  ],
                ),
              ),
              // --- Second Onboarding Screen ---
              Container(
                color: Color(0xFFDCEEE2), // Change background color
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TODO: Add the image/illustration for the second screen here
                    // TODO: Add the title for the second screen here
                    // TODO: Add the description text for the second screen here
                  ],
                ),
              ),
              // --- Third Onboarding Screen ---
              Container(
                color: Color(0xFFDCEEE2), // Change background color
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TODO: Add the image/illustration for the third screen here
                    // TODO: Add the title for the third screen here
                    // TODO: Add the description text for the third screen here
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _numPages,
                    (index) => _buildDot(index),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_currentPage < _numPages - 1) {
                      _pageController.animateToPage(
                        _numPages - 1,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeIn,
                      );
                    } else {
                      Navigator.pushReplacementNamed(context, '/signup');
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                    decoration: BoxDecoration(
                      color:
                          _currentPage < _numPages - 1
                              ? Colors.transparent
                              : Color(0xFFCA4A0C),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          _currentPage < _numPages - 1
                              ? Border.all(
                                color: Color.fromARGB(150, 202, 75, 12),
                              )
                              : null,
                    ),
                    child: Text(
                      _currentPage < _numPages - 1 ? 'Skip' : 'Sign up',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _currentPage < _numPages - 1
                                ? Color.fromARGB(150, 202, 75, 12)
                                : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
