import 'package:flutter/material.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/screens/settings/widgets/drop_down_action.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/tasks_app.dart';

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
  bool showMissed = settings.get(Setting.calendarShowMissed);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingTile(
          title: 'Initial date',
          trailing: DropDownAction(
            items: const [
              DropdownMenuItem(
                value: false,
                child: Text('Today'),
              ),
              DropdownMenuItem(
                value: true,
                child: Text('Tomorrow'),
              ),
            ],
            initialValue: settings.get(Setting.calendarInitialIstomorrow),
            onChanged: (value) {
              settings.save(
                Setting.calendarInitialIstomorrow,
                value,
              );
            },
          ),
        ),
        SettingTile.withSwitch(
          title: 'Show missed homeworks',
          value: showMissed,
          onChanged: (value) {
            settings.save(Setting.calendarShowMissed, value);
            setState(() {
              showMissed = value;
            });
            widget.changeShowMissed(value);
          },
        )
      ],
    );
  }
}
