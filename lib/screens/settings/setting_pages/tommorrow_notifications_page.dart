import 'package:flutter/material.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/notifications/notification_sender.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/switch_action.dart';
import 'package:school_manager/screens/settings/widgets/time_picker_action.dart';

class TommorrowNotificationsPage extends StatefulWidget {
  const TommorrowNotificationsPage({
    super.key,
  });

  @override
  State<TommorrowNotificationsPage> createState() =>
      _TommorrowNotificationsPageState();
}

class _TommorrowNotificationsPageState
    extends State<TommorrowNotificationsPage> {
  bool? areNotificationsAllowed;

  @override
  void initState() {
    super.initState();

    getNotificationAllowed();
  }

  void getNotificationAllowed() async {
    bool value =
        await NotificationSender.areNotificationsAllowed('tommorrow_channel');

    if (mounted) {
      setState(() {
        areNotificationsAllowed = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          if (areNotificationsAllowed == false)
            Container(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    NotificationSender.getPermission(
                            context, 'tommorrow_channel')
                        .then(
                      (value) async {
                        setState(() {
                          areNotificationsAllowed = value;
                        });
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Notifications not allowed, click here to grant permission',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SettingTile(
            label: 'Upcoming day notifications',
            highlighted: true,
            trailing: SwitchAction(
              initialValue: settings.get(Setting.tommorowNotificationEnabled),
              onChanged: (value) {
                settings.save(Setting.tommorowNotificationEnabled, value);
                if (value) {
                  NotificationSender.getPermission(
                    context,
                    'tommorrow_channel',
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Notification with homeworks and exams for next day',
            ),
          ),
          SettingTile(
            label: 'Arrival time',
            text: 'Time around which notification will arrive',
            trailing: TimePickerAction(
              initialTime:
                  settings.getTimeOfDay(Setting.tommorowNotificationTime),
              onChanged: (value) => settings.saveTimeOfDay(
                  Setting.tommorowNotificationTime, value),
            ),
          ),
          SettingTile(
            label: 'Send upcoming day notification now',
            onTap: () => NotificationSender.scheduleTommorrowNotification(
                scheduled: false),
          ),
        ],
      ),
    );
  }
}
