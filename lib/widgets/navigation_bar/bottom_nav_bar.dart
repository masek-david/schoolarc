import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.pageIndex,
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
      destinations: <Widget>[
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: context.loc.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_month_outlined),
          selectedIcon: const Icon(Icons.calendar_month),
          label: context.loc.calendar,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outlined),
          selectedIcon: const Icon(Icons.person),
          label: context.loc.personal,
        ),
        NavigationDestination(
          icon: const Icon(Icons.group_outlined),
          selectedIcon: const Icon(Icons.group),
          label: context.loc.group,
        ),
      ],
    );
  }
}
