import 'package:flutter/material.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

class HomeSettings extends StatefulWidget {
  const HomeSettings({
    super.key,
    required this.onChanged,
  });

  final void Function() onChanged;

  @override
  State<HomeSettings> createState() => _HomeSettingsState();
}

class _HomeSettingsState extends State<HomeSettings> {
  bool showMyName = settings.get(Setting.homeShowUserName);
  bool showMeals = settings.get(Setting.useMeals);
  bool showBaka = settings.get(Setting.useBakalari);
  TimeOfDay lunchTime = settings.get(Setting.mealsShowTodayUntil);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingTile.withSwitch(
          title: context.loc.showMyName,
          subtitle: context.loc.showMyNameSubtitle,
          value: showMyName,
          onChanged: (value) {
            settings.save(Setting.homeShowUserName, value);
            setState(() {
              showMyName = value;
            });
            widget.onChanged();
          },
        ),
        SettingTile.withSwitch(
          title: context.loc.showBakalariTimetable,
          value: showBaka,
          onChanged: (value) {
            settings.save(Setting.useBakalari, value);
            setState(() {
              showBaka = value;
            });
            widget.onChanged();
          },
        ),
        SettingTile.withSwitch(
          title: context.loc.showMeals,
          value: showMeals,
          onChanged: (value) {
            settings.save(Setting.useMeals, value);
            setState(() {
              showMeals = value;
            });
            widget.onChanged();
          },
        ),
        SettingTile.withTimePicker(
          title: context.loc.lunchTime,
          subtitle: context.loc.lunchTimeSubtitle,
          time: lunchTime,
          onChanged: (value) {
            settings.save(Setting.mealsShowTodayUntil, value);
            setState(() {
              lunchTime = value;
            });
            widget.onChanged();
          },
        ),
      ],
    );
  }
}
