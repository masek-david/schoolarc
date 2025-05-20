import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    this.pageIndex = 0,
    required this.onTap,
  });

  final int pageIndex;
  final void Function({required int newScreenIndex}) onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (index) {
        HapticFeedback.lightImpact();
        onTap(newScreenIndex: index);
      },
      selectedIndex: pageIndex,
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.home_work_outlined),
          selectedIcon: Icon(Icons.home_work),
          label: 'Homeworks',
        ),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: 'Exams',
        ),
      ],
    );
  }
}
