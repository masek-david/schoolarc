import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/screens/bakalari/bakalari_login_screen.dart';
import 'package:school_manager/screens/changelog_screen.dart';
import 'package:school_manager/screens/firestore_login/firebase_login_screen.dart';
import 'package:school_manager/screens/logs/logs_screen.dart';
import 'package:school_manager/screens/settings/setting_pages/style_motion_page.dart';
import 'package:school_manager/screens/settings/setting_pages/theme_page.dart';
import 'package:school_manager/screens/settings/widgets/import_export_row.dart';
import 'package:school_manager/screens/settings/widgets/package_info.dart';
import 'package:school_manager/screens/strava_cz/strava_login_screen.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/notifications/notification_sender.dart';
import 'package:school_manager/screens/settings/setting_pages/tomorrow_notifications_page.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.refreshTheme,
  });

  final void Function() refreshTheme;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool showDebug = settings.get(Setting.showDebugInfo);
  bool showFirebase = settings.get(Setting.useFirebase);
  bool useExperimentalHwOverlay = settings.get(Setting.expUseHwOverlay);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SettingTile(
            title: 'Color theme',
            subtitle: 'Customize the colors of the app',
            icon: Icons.palette_outlined,
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => ThemePage(
                  refreshTheme: widget.refreshTheme,
                ),
              ),
            ),
          ),
          SettingTile(
            title: 'Style & Motion',
            subtitle: 'Customize animations and more',
            icon: Icons.animation,
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => StyleMotionPage(
                  refreshTheme: widget.refreshTheme,
                ),
              ),
            ),
          ),
          SettingTile(
            title: 'Upcoming day notifications',
            subtitle: 'Notification with homeworks and exams for next day',
            icon: Icons.notifications_outlined,
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: (context) => navigatorKey.currentState
                ?.push(
              MaterialPageRoute(
                builder: (context) => const TomorrowNotificationsPage(),
              ),
            )
                .then(
              (value) {
                NotificationSender.scheduletomorrowNotification(
                    showSnackbar: (text) => showMessage(context, text));
              },
            ),
          ),
          Divider(),
          SettingTile(
            title: 'Bakaláři login',
            icon: Icons.hexagon_outlined,
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const BakaLoginScreen(),
              ),
            ),
          ),
          SettingTile(
            title: 'Strava.cz login',
            icon: Icons.food_bank_outlined,
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const StravaLoginScreen(),
              ),
            ),
          ),
          AnimatedSize(
            duration: Durations.medium1,
            child: SizedBox(
              height: showFirebase ? null : 0,
              child: SettingTile(
                title: 'Firebase login',
                icon: Icons.fireplace,
                onTap: (context) => navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => const FirebaseLoginScreen(),
                  ),
                ),
              ),
            ),
          ),
          Divider(),
          ImportExportRow(),
          SettingTile(
            title: 'View app changelog',
            icon: Icons.data_object,
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const ChangelogScreen(),
              ),
            ),
          ),
          if (showDebug)
            SettingTile(
              title: 'View app logs',
              icon: Icons.data_array,
              onTap: (context) => navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => const LogsScreen(),
                ),
              ),
            ),
          if (showDebug)
          Divider(),
          if (showDebug || kDebugMode)
            SettingTile.withSwitch(
                title: 'Developer mode',
                value: showDebug,
                onChanged: (value) {
                  settings.save(Setting.showDebugInfo, value);
                  setState(() {
                    showDebug = value;
                  });
                }),
          if (showDebug)
            SettingTile.withSwitch(
              title: 'Use firebase',
              value: showFirebase,
              onChanged: (value) {
                settings.save(Setting.useFirebase, value);
                setState(() {
                  showFirebase = value;
                });
              },
            ),
          if (showDebug)
            SettingTile.withSwitch(
              title: 'Use experimental homework tile overlay',
              value: useExperimentalHwOverlay,
              onChanged: (value) {
                settings.save(Setting.expUseHwOverlay, value);
                setState(() {
                  useExperimentalHwOverlay = value;
                });
                widget.refreshTheme();
              },
            ),
          if (showDebug)
            Center(
              child: Text(
                packageInfo.packageName,
                style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest),
              ),
            ),
          Center(
              child: PackageInfoWidget(
            onBecameDev: () => setState(() {
              showDebug = true;
              settings.save(Setting.showDebugInfo, true);
            }),
          ))
        ],
      ),
    );
  }
}
