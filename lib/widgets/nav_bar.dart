import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({
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
        onTap(newScreenIndex: index);
      },
      selectedIndex: pageIndex,
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.home_work),
          label: 'Homeworks',
        ),
        NavigationDestination(
          icon: Icon(Icons.description),
          label: 'Exams',
        ),
      ],
    );
  }
}
