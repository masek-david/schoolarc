import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/screens/bakalari/bakalari_login_screen.dart';
import 'package:school_manager/screens/firebase_login/firebase_login_screen.dart';
import 'package:school_manager/screens/settings/about_app.dart';
import 'package:school_manager/screens/settings/setting_pages/localization_page.dart';
import 'package:school_manager/screens/settings/setting_pages/shortcuts_page.dart';
import 'package:school_manager/screens/settings/setting_pages/style_motion_page.dart';
import 'package:school_manager/screens/settings/setting_pages/theme_page.dart';
import 'package:school_manager/screens/settings/setting_pages/tomorrow_notifications_page.dart';
import 'package:school_manager/screens/settings/widgets/import_export_row.dart';
import 'package:school_manager/screens/settings/widgets/package_info.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/strava_cz/strava_login_screen.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/notifications/notification_sender.dart';

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

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
      ),
      body: ListView(
        children: [
          SettingTile(
            title: loc.colorTheme,
            subtitle: loc.colorThemeDescription,
            icon: Icons.palette_outlined,
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => ThemePage(
                  refreshTheme: widget.refreshTheme,
                ),
              ),
            ),
          ),
          SettingTile(
            title: loc.styleMotion,
            subtitle: loc.styleMotionDescription,
            icon: Icons.animation,
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => StyleMotionPage(
                  refreshTheme: widget.refreshTheme,
                ),
              ),
            ),
          ),
          if (NotificationSender.isCompatiblePlatform() || kDebugMode)
            SettingTile(
              title: loc.upcomingDayNotifications,
              subtitle: loc.upcomingDayNotificationsDescription,
              icon: Icons.notifications_outlined,
              trailing: const Icon(Icons.keyboard_arrow_right),
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
          SettingTile(
            title: loc.localization,
            subtitle: loc.localizationSubtitle,
            icon: Icons.language_outlined,
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => LocalizationPage(
                  refreshTheme: widget.refreshTheme,
                ),
              ),
            ),
          ),
          SettingTile(
            title: loc.shortcuts,
            subtitle: loc.shortcutsDescription,
            icon: Icons.keyboard_alt_outlined,
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const ShortcutsPage(),
              ),
            ),
          ),
          const Divider(),
          SettingTile(
            title: loc.bakalari,
            icon: Icons.hexagon_outlined,
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const BakaLoginScreen(),
              ),
            ),
          ),
          SettingTile(
            title: loc.stravaCz,
            icon: Icons.restaurant_outlined,
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const StravaLoginScreen(),
              ),
            ),
          ),
          SettingTile(
            title: loc.cloudSync,
            icon: Icons.cloud_outlined,
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const FirebaseLoginScreen(),
              ),
            ),
          ),
          const Divider(),
          const ImportExportRow(),
          SettingTile(
            title: context.loc.aboutApp,
            icon: Icons.info_outline_rounded,
            onTap: (context) => navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const AboutApp(),
              ),
            ),
          ),
          if (showDebug || kDebugMode)
            SettingTile.withSwitch(
                title: loc.developerMode,
                value: showDebug,
                onChanged: (value) {
                  settings.save(Setting.showDebugInfo, value);
                  setState(() {
                    showDebug = value;
                  });
                }),
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
