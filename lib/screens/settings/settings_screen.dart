import 'package:flutter/material.dart';
import 'package:school_manager/screens/bakalari/bakalari_screen.dart';
import 'package:school_manager/screens/logs/logs_screen.dart';
import 'package:school_manager/screens/settings/setting_pages/theme_page.dart';
import 'package:school_manager/screens/settings/widgets/adaptive_showcase.dart';
import 'package:school_manager/screens/settings/widgets/initial_app_page.dart';
import 'package:school_manager/screens/settings/widgets/slider_action.dart';
import 'package:school_manager/screens/strava_cz/strava_settings_screen.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/utils/notifications/notification_sender.dart';
import 'package:school_manager/screens/settings/setting_pages/tommorrow_notifications_page.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/switch_action.dart';
import 'package:school_manager/tasks_app.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.refreshTheme,
  });

  final void Function() refreshTheme;

  void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SettingTile(
            label: 'App theme',
            text: 'Customize the look and feel of the app',
            icon: Icons.palette_outlined,
            onTap: () => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => ThemePage(
                  refreshTheme: refreshTheme,
                ),
              ),
            ),
          ),
          SettingTile(
            label: 'Upcoming day notifications',
            text: 'Notification with homeworks and exams for next day',
            icon: Icons.circle_notifications_outlined,
            onTap: () => navigatorKey.currentState
                ?.push(
              MaterialPageRoute(
                builder: (context) => const TommorrowNotificationsPage(),
              ),
            )
                .then(
              (value) {
                NotificationSender.scheduleTommorrowNotification(
                    showSnackbar: (text) => showSnackBar(context, text));
              },
            ),
          ),
          Divider(),
          SettingTile(
            label: 'Bakaláři login',
            icon: Icons.hexagon_outlined,
            onTap: () => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const BakalariScreen(),
              ),
            ),
          ),
          SettingTile(
            label: 'Strava cz login',
            icon: Icons.food_bank_outlined,
            onTap: () => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const StravaSettingsScreen(),
              ),
            ),
          ),
          Divider(),
          InitialAppPage(),
          SettingTile(
            label: 'Screen switching animation duration',
            text: 'In miliseconds (0 disables animation)',
            icon: Icons.timelapse,
            newLineAction: SliderAction(
              inititalValue: settings.get(Setting.pageSwitchAnimationDuration),
              divisions: 10,
              min: 0,
              max: 500,
              onChanged: (value) {
                settings.save(Setting.pageSwitchAnimationDuration, value);
              },
            ),
          ),
          SettingTile(
            label: 'Show app border',
            text: 'On big screen, show borders in the app',
            trailing: SwitchAction(
              initialValue: settings.get(Setting.showAppOverlay),
              onChanged: (value) {
                settings.save(Setting.showAppOverlay, value);
                refreshTheme();
              },
            ),
          ),
          Divider(),
          SettingTile(
            label: 'View app logs',
            icon: Icons.data_array,
            onTap: () => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const LogsScreen(),
              ),
            ),
          ),
          SettingTile(
            label: 'Show debug info',
            trailing: SwitchAction(
              initialValue: settings.get(Setting.showDebugInfo),
              onChanged: (value) {
                settings.save(Setting.showDebugInfo, value);
                refreshTheme();
              },
            ),
          ),
          if (settings.get(Setting.showDebugInfo)) AdaptiveShowcase(),
        ],
      ),
    );
  }
}
