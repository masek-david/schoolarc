import 'package:flutter/material.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

class SideNavBar extends StatelessWidget {
  const SideNavBar({
    super.key,
    required this.pageIndex,
    required this.onTap,
  });

  final int pageIndex;
  final void Function({required int newScreenIndex}) onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: pageIndex,
      onDestinationSelected: (index) {
        onTap(newScreenIndex: index);
      },
      labelType: NavigationRailLabelType.all,
      groupAlignment: 0.0,
      // backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      leading: const DrawerButton(onPressed: switchDrawer),
      trailing: const Icon(Icons.abc, color: Colors.transparent),
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
          label: Text(context.loc.homeworks(2)),
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
