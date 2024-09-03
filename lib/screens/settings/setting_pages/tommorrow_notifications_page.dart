import 'package:flutter/material.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/switch_action.dart';
import 'package:school_manager/screens/settings/widgets/time_picker_action.dart';

class TommorrowNotificationsPage extends StatelessWidget {
  const TommorrowNotificationsPage({
    super.key,
    required this.settings,
  });

  final SettingsDatabase settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          SettingTile(
            label: 'Upcoming day notifications',
            // text: 'Time around which notification will arrive',
            highlighted: true,
            action: SwitchAction(
              initialValue: settings.tommorrowNotificationEnabled(),
              onChanged: settings.setTommorowNotificationEnabled,
            ),
          ),
          SettingTile(
            label: 'Arrival time',
            text: 'Time around which notification will arrive',
            action: TimePickerAction(
              initialTime: settings.tommorowNotificationTime(),
              onChanged: settings.setTommorowNotificationTime,
            ),
          ),
        ],
      ),
    );
  }
}
