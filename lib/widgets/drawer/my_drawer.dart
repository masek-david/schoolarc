import 'package:flutter/material.dart';
import 'package:school_manager/screens/db_info.dart';
import 'package:school_manager/screens/settings/settings_screen.dart';
import 'package:school_manager/screens/subjects/subjects_screen.dart';
import 'package:school_manager/widgets/drawer/drawer_button.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
    required this.setThemeMode,
  });

  final void Function(bool? value) setThemeMode;

  void showSnackbar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 10),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 28, bottom: 20, top: 20),
          child: Text('School app', style: TextStyle(fontSize: 20)),
        ),
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
          text: 'View database',
          icon: const Icon(Icons.data_array),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DbInfoScreen(),
            ),
          ),
        ),
        MyDrawerButton(
          text: 'Settings',
          icon: const Icon(Icons.settings),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  setThemeMode: setThemeMode,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
