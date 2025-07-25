import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/baka_login_notifier.dart';
import 'package:schoolarc/provider/firebase_login_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava_login_notifier.dart';
import 'package:schoolarc/provider/use_cloudsync_notifier.dart';
import 'package:schoolarc/screens/bakalari/bakalari_login_screen.dart';
import 'package:schoolarc/screens/firebase_login/firebase_login_screen.dart';
import 'package:schoolarc/screens/settings/about_app.dart';
import 'package:schoolarc/screens/settings/setting_pages/localization_page.dart';
import 'package:schoolarc/screens/settings/setting_pages/shortcuts_page.dart';
import 'package:schoolarc/screens/settings/setting_pages/style_motion_page.dart';
import 'package:schoolarc/screens/settings/setting_pages/theme_page.dart';
import 'package:schoolarc/screens/settings/setting_pages/tomorrow_notifications_page.dart';
import 'package:schoolarc/screens/settings/widgets/import_export_row.dart';
import 'package:schoolarc/screens/settings/widgets/package_info.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/strava_cz/strava_login_screen.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/notifications/notification_sender.dart';
import 'package:schoolarc/widgets/login_status_icon.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = context.loc;
    final debugMode = ref.watch(debugModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
      ),
      body: ListView(
        children: [
          SettingTile(
            title: loc.colorTheme,
            subtitle: loc.colorThemeDescription,
            leading: const Icon(Icons.palette_outlined),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: (context) => pushScreen(context, const ThemePage()),
          ),
          SettingTile(
            title: loc.styleMotion,
            subtitle: loc.styleMotionDescription,
            leading: const Icon(Icons.animation),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: (context) => pushScreen(context, const StyleMotionPage()),
          ),
          if (NotificationSender.isCompatiblePlatform() || kDebugMode)
            SettingTile(
              title: loc.upcomingDayNotifications,
              subtitle: loc.upcomingDayNotificationsDescription,
              leading: const Icon(Icons.notifications_outlined),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: (context) => pushScreen(
                context,
                const TomorrowNotificationsPage(),
              ).then(
                (value) {
                  NotificationSender.scheduletomorrowNotification(
                      showSnackbar: (text) => showMessage(context, text));
                },
              ),
            ),
          SettingTile(
            title: loc.localization,
            subtitle: loc.localizationSubtitle,
            leading: const Icon(Icons.language_outlined),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: (context) => pushScreen(context, const LocalizationPage()),
          ),
          SettingTile(
            title: loc.shortcuts,
            subtitle: loc.shortcutsDescription,
            leading: const Icon(Icons.keyboard_alt_outlined),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: (context) => pushScreen(context, const ShortcutsPage()),
          ),
          const Divider(),
          SettingTile(
            title: loc.bakalari,
            leading: const Icon(Icons.hexagon_outlined),
            onTap: (context) => pushScreen(context, const BakaLoginScreen()),
            trailing: LoginStatusIcon(
              provider: bakaLoginProvider,
              showProvider: useBakaProvider,
            ),
          ),
          SettingTile(
            title: loc.stravaCz,
            leading: const Icon(Icons.restaurant_outlined),
            onTap: (context) => pushScreen(context, const StravaLoginScreen()),
            trailing: LoginStatusIcon(
              provider: stravaLoginProvider,
              showProvider: useMealsProvider,
            ),
          ),
          SettingTile(
            title: loc.cloudSync,
            leading: const Icon(Icons.cloud_outlined),
            onTap: (context) =>
                pushScreen(context, const FirebaseLoginScreen()),
            trailing: LoginStatusIcon(
              provider: firebaseLoginProvider,
              showProvider: useCloudSyncProvider,
            ),
          ),
          const Divider(),
          const ImportExportRow(),
          SettingTile(
            title: context.loc.aboutApp,
            leading: const Icon(Icons.info_outline_rounded),
            onTap: (context) => pushScreen(context, const AboutApp()),
          ),
          if (debugMode || kDebugMode)
            SettingTile.withSwitch(
                title: loc.developerMode,
                value: debugMode,
                onChanged: (value) {
                  ref.read(debugModeProvider.notifier).set(value);
                }),
          if (debugMode)
            Center(
              child: Text(
                packageInfo.packageName,
                style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest),
              ),
            ),
          const Center(
            child: PackageInfoWidget(enableTap: true),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
