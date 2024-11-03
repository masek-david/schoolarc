import 'package:flutter/material.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/screens/settings/widgets/drop_down_action.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';

class CalendarSettings extends StatefulWidget {
  const CalendarSettings({super.key});

  @override
  State<CalendarSettings> createState() => _CalendarSettingsState();
}

class _CalendarSettingsState extends State<CalendarSettings> {
  final _settings = SettingsDatabase();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingTile(
          label: 'Initial date',
          action: DropDownAction(
            items: const [
              DropdownMenuItem(
                child: Text('Today'),
                value: false,
              ),
              DropdownMenuItem(
                child: Text('Tommorrow'),
                value: true,
              ),
            ],
            initialValue: _settings.get(Setting.calendarInitialIsTommorrow),
            onChanged: (value) {
              _settings.save(
                Setting.calendarInitialIsTommorrow,
                value,
              );
            },
          ),
        ),
      ],
    );
  }
}
