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
      leading: DrawerButton(onPressed: switchDrawer,),
      groupAlignment: 0.0,
      labelType: NavigationRailLabelType.all,
      onDestinationSelected: (index) {
        onTap(newScreenIndex: index);
      },
      selectedIndex: pageIndex,
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_month),
          label: Text('Calendar'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.home_work),
          label: Text('Homeworks'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.description),
          label: Text('Exams'),
        ),
      ],
    );
  }
}