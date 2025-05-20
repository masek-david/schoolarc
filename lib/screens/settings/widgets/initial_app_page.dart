import 'package:flutter/material.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/navigation_bar/bottom_nav_bar.dart';

class InitialAppPage extends StatefulWidget {
  const InitialAppPage({super.key});

  @override
  State<InitialAppPage> createState() => _InitialAppPageState();
}

class _InitialAppPageState extends State<InitialAppPage> {
  int appPage = settings.get(Setting.initialAppPage);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingTile(
          title: 'Initial page',
          subtitle: 'The page that will be displayed when opening the app',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BottomNavBar(
              pageIndex: appPage,
              onTap: ({required newScreenIndex}) {
                settings.save(Setting.initialAppPage, newScreenIndex);
                setState(() {
                  appPage = newScreenIndex;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
