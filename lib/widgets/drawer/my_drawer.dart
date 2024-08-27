import 'package:flutter/material.dart';
import 'package:school_manager/screens/settings/settings_screen.dart';
import 'package:school_manager/screens/subjects/subjects_screen.dart';
import 'package:school_manager/widgets/drawer/drawer_button.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        MyDrawerButton(
          text: 'Subjects',
          icon: const Icon(Icons.school_outlined),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubjectsScreen(),
              ),
            );
          },
        ),
        const Divider(indent: 28, endIndent: 28),
        MyDrawerButton(
          text: 'Settings',
          icon: const Icon(Icons.settings),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
