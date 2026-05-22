import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.index,
    required this.onTap,
    required this.body,
    required this.title,
    this.topBanner,
  });

  final int index;
  final ValueChanged<int> onTap;
  final Widget body;
  final String title;
  final Widget? topBanner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: body),
            if (topBanner != null)
              Positioned(
                top: 8,
                right: 12,
                child: topBanner!,
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: 'Tag'),
          BottomNavigationBarItem(
              icon: Icon(Icons.apartment_outlined), label: 'Location'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
