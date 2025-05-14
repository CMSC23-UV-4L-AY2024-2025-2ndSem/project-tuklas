import 'package:flutter/material.dart';
import '../widgets/main_navigation_bar.dart';
import '../widgets/add_overlay.dart';
import 'travel_plan.dart';
import 'travel_buddy.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _showOverlay = false;

  final List<Widget> _screens = [
    const TravelPlanScreen(),
    const SizedBox(), // empty yet for the add button
    TravelBuddyScreen(),
  ];

  void _onButtonPressed(int index) {
    if (index == 1) {
      setState(() => _showOverlay = !_showOverlay);
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
          MainNavigationBar(
            selectedIndex: _selectedIndex,
            onButtonPressed: _onButtonPressed,
          ),
          if (_showOverlay)
            AddOverlay(onClose: () => setState(() => _showOverlay = false)),
          // single navigation bar that stays on top
        ],
      ),
    );
  }
}