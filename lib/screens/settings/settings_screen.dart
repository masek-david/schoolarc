import 'package:flutter/material.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/notifications/notification_sender.dart';
import 'package:school_manager/screens/settings/setting_pages/quick_add_notification_page.dart';
import 'package:school_manager/screens/settings/setting_pages/tommorrow_notifications_page.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsDatabase settings = SettingsDatabase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SettingTile(
            label: 'Upcoming day notifications',
            text: 'Notification with homeworks and exams for next day',
            icon: const Icon(Icons.circle_notifications_outlined),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TommorrowNotificationsPage(
                  settings: settings,
                ),
              ),
            ).then((value) {
              NotificationSender.scheduleTommorrowNotification(showSnackbar: (text) => showSnackBar(context, text));
            },)
          ),
          SettingTile(
            label: 'Quick add notifications',
            text: 'Add homeworks and exams right from your notification',
            icon: const Icon(Icons.notification_add_outlined),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuickAddNotificationPage(
                  settings: settings,
                ),
              ),
            ).then((value) {
              NotificationSender.sendQuickAdd(true);
            },)
          ),
          SettingTile(
            label: 'Send simple notification (debugging)',
            icon: const Icon(Icons.android),
            onTap: () => NotificationSender.sendSimpleNotification(),
          ),
        ],
      ),
    );
  }
}
