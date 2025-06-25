import 'package:flutter/material.dart';
import 'package:school_manager/screens/settings/widgets/initial_app_page.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/slider_action.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

class StyleMotionPage extends StatefulWidget {
  const StyleMotionPage({super.key, required this.refreshTheme});

  final void Function() refreshTheme;

  @override
  State<StyleMotionPage> createState() => _StyleMotionPageState();
}

class _StyleMotionPageState extends State<StyleMotionPage> {
  bool showBorder = settings.get(Setting.showAppOverlay);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          InitialAppPage(),
          SettingTile(
            title: 'Screen switching animation duration',
            subtitle: 'In miliseconds (0 disables animation)',
            icon: Icons.timelapse,
            newLineAction: SliderAction(
              inititalValue: settings.get(Setting.pageSwitchAnimationDuration),
              divisions: 10,
              min: 0,
              max: 500,
              onChanged: (value) {
                settings.save(Setting.pageSwitchAnimationDuration, value);
              },
            ),
          ),
          SettingTile.withSwitch(
            title: 'Show app border',
            subtitle: 'On big screen or in landscape, show borders in the app',
            value: showBorder,
            onChanged: (value) {
              settings.save(Setting.showAppOverlay, value);
              setState(() {
                showBorder = value;
              });
              widget.refreshTheme();
            },
          ),
        ],
      ),
    );
  }
}
