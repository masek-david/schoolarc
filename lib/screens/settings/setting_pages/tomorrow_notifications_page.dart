import 'package:flutter/material.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/globals.dart';
import 'package:school_manager/utils/notifications/notification_sender.dart';

class TomorrowNotificationsPage extends StatefulWidget {
  const TomorrowNotificationsPage({super.key});

  @override
  State<TomorrowNotificationsPage> createState() =>
      _TomorrowNotificationsPageState();
}

class _TomorrowNotificationsPageState extends State<TomorrowNotificationsPage> {
  bool? areNotificationsAllowed;
  bool enabled = settings.get(Setting.tomorrowNotificationEnabled);
  TimeOfDay time = settings.get(Setting.tomorrowNotificationTime);

  @override
  void initState() {
    super.initState();
    getNotificationAllowed();
  }

  void getNotificationAllowed() async {
    bool value =
        await NotificationSender.areNotificationsAllowed('tomorrow_channel');

    if (mounted) {
      setState(() {
        areNotificationsAllowed = value;
      });
    }
  }

  void setEnabled(bool value) async {
    setState(() {
      enabled = value;
    });
    settings.save(Setting.stopAskingForNotifications, false);
    if (value) {
      bool nowHasPermission = await NotificationSender.getPermission(
        context,
        'tomorrow_channel',
      );
      if (nowHasPermission == false) {
        setState(() {
          enabled = false;
        });
      } else {
        settings.save(Setting.tomorrowNotificationEnabled, value);
        setState(() {
          areNotificationsAllowed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.upcomingDayNotifications),
      ),
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
                            context, 'tomorrow_channel')
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
                      loc.notificationsNotAllowedMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SettingTile.withSwitch(
            title: loc.upcomingDayNotifications,
            highlighted: true,
            onChanged: setEnabled,
            value: enabled,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(loc.upcomingDayNotificationsDescription),
          ),
          SettingTile.withTimePicker(
            title: loc.arrivalTimeTitle,
            subtitle: loc.arrivalTimeSubtitle,
            time: time,
            onChanged: (value) {
              settings.save(Setting.tomorrowNotificationTime, value);
              setState(() {
                time = value;
              });
            },
          ),
          SettingTile(
            title: loc.sendNotificationNow,
            enabled: areNotificationsAllowed == true,
            onTap: (context) => NotificationSender.scheduletomorrowNotification(
              scheduled: false,
            ),
          ),
        ],
      ),
    );
  }
}
