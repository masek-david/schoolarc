import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
    this.initialIndex = 0,
    required this.onTap,
  });

  final int initialIndex;
  final void Function({required int newScreenIndex}) onTap;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    int currentPageIndex = widget.initialIndex;
    return NavigationBar(
      backgroundColor:
          Theme.of(context).colorScheme.secondaryContainer.withAlpha(82),
      onDestinationSelected: (index) {
        currentPageIndex = index;
        widget.onTap(newScreenIndex: index);
      },
      selectedIndex: currentPageIndex,
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
