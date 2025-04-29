import 'package:flutter/material.dart';

class MainNavigationBar extends StatelessWidget {
  final int selectedIndex; // current index
  final Function(int)
  onButtonPressed; // callback function based on 'index' of screen

  const MainNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        // the nav bar container ui
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            // the buttons container
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => onButtonPressed(0),
                icon: Icon(
                  Icons.home_outlined,
                  size: 28,
                  color:
                      selectedIndex == 0
                          ? const Color(0xFF14645B)
                          : Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 40),
              GestureDetector(
                onTap: () => onButtonPressed(1),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 216, 92, 42),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 40),
              IconButton(
                onPressed: () => onButtonPressed(2),
                icon: Icon(
                  Icons.person_outline,
                  size: 28,
                  color:
                      selectedIndex == 2
                          ? const Color(0xFF14645B)
                          : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
