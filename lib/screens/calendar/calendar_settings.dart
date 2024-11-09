import 'package:flutter/material.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/screens/settings/widgets/drop_down_action.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/switch_action.dart';

class CalendarSettings extends StatefulWidget {
  const CalendarSettings({
    super.key,
    required this.changeShowMissed,
  });

  final void Function(bool value) changeShowMissed;

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
                value: false,
                child: Text('Today'),
              ),
              DropdownMenuItem(
                value: true,
                child: Text('Tommorrow'),
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
        SettingTile(
          label: 'Show missed homeworks',
          action: SwitchAction(
            initialValue: _settings.get(
              Setting.calendarShowMissed,
            ),
            onChanged: (value) {
              _settings.save(
              Setting.calendarShowMissed, value
            );
            widget.changeShowMissed(value);
            },
          ),
        )
      ],
    );
  }
}
