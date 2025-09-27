import 'package:flutter/material.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/navigation_bar/bottom_nav_bar.dart';

class InitialAppPage extends StatefulWidget {
  const InitialAppPage({super.key});

  @override
  State<InitialAppPage> createState() => _InitialAppPageState();
}

class _InitialAppPageState extends State<InitialAppPage> {
  int appPage = settings.get(Setting.initialAppPage);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
    );
  }
}
