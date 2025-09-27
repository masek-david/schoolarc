import 'package:flutter/material.dart';
import 'package:schoolarc/main_app.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class SideNavBar extends StatelessWidget {
  const SideNavBar({
    super.key,
    required this.pageIndex,
    required this.onTap,
    this.action,
  });

  final int pageIndex;
  final void Function({required int newScreenIndex}) onTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: pageIndex,
      onDestinationSelected: (index) {
        onTap(newScreenIndex: index);
      },
      labelType: NavigationRailLabelType.all,
      groupAlignment: 0.0,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      leading: const DrawerButton(onPressed: openDrawer),
      trailingAtBottom: true,
      trailing: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: action ?? const SizedBox(height: 48)),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(context.loc.home),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.calendar_month_outlined),
          selectedIcon: const Icon(Icons.calendar_month),
          label: Text(context.loc.calendar),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.home_work_outlined),
          selectedIcon: const Icon(Icons.home_work),
          label: Text(context.loc.homework(2)),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.description_outlined),
          selectedIcon: const Icon(Icons.description),
          label: Text(context.loc.exams(2)),
        ),
      ],
    );
  }
}
