import 'package:flutter/material.dart';
import 'package:school_manager/tasks_app.dart';

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
      leading: DrawerButton(onPressed: switchDrawer),
      trailing: Icon(Icons.abc, color: Colors.transparent),
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: Text('Calendar'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.home_work_outlined),
          selectedIcon: Icon(Icons.home_work),
          label: Text('Homeworks'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: Text('Exams'),
        ),
      ],
    );
  }
}
