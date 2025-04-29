import 'package:flutter/material.dart';
import '../widgets/main_navigation_bar.dart';
import 'dummy.dart';
import 'travel_buddy.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DummyScreen(),
    const SizedBox(), // empty yet for the add button
    TravelBuddyScreen(),
  ];

  void _onButtonPressed(int index) {
    if (index == 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add Button Pressed')));
      return;
    }

    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // main content area
          _screens[_selectedIndex],
          // single navigation bar that stays on top
          MainNavigationBar(
            selectedIndex: _selectedIndex,
            onButtonPressed: _onButtonPressed,
          ),
        ],
      ),
    );
  }
}
