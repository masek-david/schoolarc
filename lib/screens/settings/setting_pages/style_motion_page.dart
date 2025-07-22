import 'package:flutter/material.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/screens/settings/widgets/initial_app_page.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/slider_action.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

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
      appBar: AppBar(
        title: Text(context.loc.styleMotion),
      ),
      body: ListView(
        children: [
          const InitialAppPage(),
          SettingTile(
            title: context.loc.styleMotionScreenSwitchAnimationTitle,
            subtitle: context.loc.styleMotionScreenSwitchAnimationSubtitle,
            leading: const Icon(Icons.timelapse),
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
            title: context.loc.styleMotionShowBorderTitle,
            subtitle: context.loc.styleMotionShowBorderSubtitle,
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
