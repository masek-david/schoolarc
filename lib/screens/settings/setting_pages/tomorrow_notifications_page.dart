import 'package:flutter/material.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/notifications/notification_sender.dart';

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

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        NotificationSender.scheduletomorrowNotification(
          showSnackbar: (text) => showMessage(context, text),
        );
      },
      child: SettingsScaffold(
        heroTag: 'notifications',
        title: loc.upcomingDayNotifications,
        children: [
          if (areNotificationsAllowed == false)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.errorContainer,
              ),
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
            isFirst: true,
            title: loc.upcomingDayNotifications,
            highlighted: true,
            onChanged: setEnabled,
            value: enabled,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(loc.upcomingDayNotificationsDescription),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Notification will be received only if you open the app that day.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          SettingTile.withTimePicker(
            isFirst: true,
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
            isLast: true,
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
