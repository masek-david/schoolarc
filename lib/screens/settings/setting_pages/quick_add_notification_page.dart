import 'package:flutter/material.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/notifications/notification_sender.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/switch_action.dart';
import 'package:school_manager/screens/settings/widgets/time_picker_action.dart';

class QuickAddNotificationPage extends StatelessWidget {
  const QuickAddNotificationPage({
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
            label: 'Quick add notification',
            highlighted: true,
            action: SwitchAction(
              initialValue: settings.get(DbKeys.quickAddEnabled),
              onChanged: (value) {
                settings.save(DbKeys.quickAddEnabled, value);
                if (value) {
                  NotificationSender.getPermission(context);
                }
              },
            ),
          ),
          SettingTile(
            label: 'Arrival time',
            text:
                'When the notification will automatically arrive to your notifications',
            action: TimePickerAction(
              initialTime: settings.getTimeOfDay(DbKeys.quickAddArriveTime),
              onChanged: (value) => settings.saveTimeOfDay(DbKeys.quickAddArriveTime, value),
            ),
          ),
          SettingTile(
            label: 'Dissappear time',
            text:
                'When the notification will automatically dissappear from your notifications',
            action: TimePickerAction(
              initialTime: settings.getTimeOfDay(DbKeys.quickAddDissappearTime),
              onChanged:(value) => settings.saveTimeOfDay(DbKeys.quickAddDissappearTime, value),
            ),
          ),
          SettingTile(
            label: 'On weekends',
            text: 'Whether the notification should arrive on weekends',
            action: SwitchAction(
              initialValue: settings.get(DbKeys.quickAddOnWeekends),
              onChanged: (value) => settings.save(DbKeys.quickAddOnWeekends, value),
            ),
          ),
          SettingTile(
            label: 'Send Quick add now',
            text:
                'Sends the notification now, it will stay until you dismiss it',
            onTap: () => NotificationSender.sendQuickAdd(false),
          ),
        ],
      ),
    );
  }
}
