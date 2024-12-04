import 'package:flutter/material.dart';
import 'package:school_manager/screens/settings/widgets/time_picker_action.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/tasks_app.dart';

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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingTile(
          label: 'Lunch time',
          text: 'When meals for next day appear',
          action: TimePickerAction(
            initialTime: settings.getTimeOfDay(Setting.mealsShowTodayUntil),
            onChanged: (time) {
              settings.saveTimeOfDay(Setting.mealsShowTodayUntil, time);
              widget.onChanged();
            },
          ),
        ),
      ],
    );
  }
}
