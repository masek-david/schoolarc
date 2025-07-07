import 'package:flutter/material.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/screens/settings/widgets/drop_down_action.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

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
  bool showArrows = settings.get(Setting.calendarShowArrows);
  bool initialIsTomorrow = settings.get(Setting.calendarInitialIsTomorrow);

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingTile(
          title: loc.initialDate,
          trailing: DropDownAction(
            value: initialIsTomorrow,
            items: [
              DropdownMenuItem(
                value: false,
                child: Text(loc.today),
              ),
              DropdownMenuItem(
                value: true,
                child: Text(loc.tomorrow),
              ),
            ],
            onChanged: (value) {
              settings.save(Setting.calendarInitialIsTomorrow, value);
              setState(() {
                initialIsTomorrow = value as bool;
              });
            },
          ),
        ),
        SettingTile.withSwitch(
          title: loc.showMissedHomeworks,
          value: showMissed,
          onChanged: (value) {
            settings.save(Setting.calendarShowMissed, value);
            setState(() {
              showMissed = value;
            });
            widget.changeShowMissed(value);
          },
        ),
        SettingTile.withSwitch(
          title: loc.showArrows,
          subtitle: loc.showArrowsSubtitle,
          value: showArrows,
          onChanged: (value) {
            settings.save(Setting.calendarShowArrows, value);
            setState(() {
              showArrows = value;
            });
            widget.changeShowMissed(showMissed);
          },
        ),
      ],
    );
  }
}
