import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key, required this.onTap});

  final void Function({required int newScreenIndex}) onTap;

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
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
          icon: Icon(Icons.home_work),
          label: 'Homeworks',
        ),
        NavigationDestination(
          icon: Icon(Icons.school),
          label: 'Exams',
        ),
      ],
    );
  }
}
