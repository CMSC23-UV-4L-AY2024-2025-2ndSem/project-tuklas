import 'package:flutter/material.dart';
import 'package:project_TUKLAS/screens/addplan_page.dart';
import '../widgets/main_navigation_bar.dart';
import 'travel_plan.dart';
import 'travel_buddy.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TravelPlanScreen(),
    const SizedBox(), // empty yet for the add button
    TravelBuddyScreen(),
  ];

  void _onButtonPressed(int index) {
    if (index == 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add Button Pressed')));

      //Pau: temporarily added to test add to plan page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddtravelPage()),
      );
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
