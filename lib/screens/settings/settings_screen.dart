import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/bakalari/baka_login_notifier.dart';
import 'package:schoolarc/provider/firebase/firebase_login_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_login_notifier.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/import_export_row.dart';
import 'package:schoolarc/screens/settings/widgets/package_info.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
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

    return SettingsScaffold(
      heroTag: 'settings',
      title: loc.settings,
      children: [
        SettingTile(
          heroTag: 'theme',
          isFirst: true,
          title: loc.colorTheme,
          subtitle: loc.colorThemeDescription,
          leading: const Icon(Icons.palette_outlined),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: (context) =>
              Navigator.restorablePushNamed(context, '/settings/theme'),
        ),
        SettingTile(
          heroTag: 'style',
          title: loc.styleMotion,
          subtitle: loc.styleMotionDescription,
          leading: const Icon(Icons.animation),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: (context) =>
              Navigator.restorablePushNamed(context, '/settings/style'),
        ),
        if (NotificationSender.isCompatiblePlatform() || kDebugMode)
          SettingTile(
            heroTag: 'notifications',
              title: loc.upcomingDayNotifications,
              subtitle: loc.upcomingDayNotificationsDescription,
              leading: const Icon(Icons.notifications_outlined),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: (context) {
                Navigator.restorablePushNamed(
                  context,
                  '/settings/notifications',
                );
              }),
        SettingTile(
          heroTag: 'localizations',
          title: loc.localization,
          subtitle: loc.localizationSubtitle,
          leading: const Icon(Icons.language_outlined),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: (context) =>
              Navigator.restorablePushNamed(context, '/settings/localization'),
        ),
        SettingTile(
          heroTag: 'shortcuts',
          isLast: true,
          title: loc.shortcuts,
          subtitle: loc.shortcutsDescription,
          leading: const Icon(Icons.keyboard_alt_outlined),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: (context) =>
              Navigator.restorablePushNamed(context, '/settings/shortcuts'),
        ),
        SettingTile(
          heroTag: 'bakalari',
          isFirst: true,
          title: loc.bakalari,
          leading: const Icon(Icons.hexagon_outlined),
          onTap: (context) =>
              Navigator.restorablePushNamed(context, '/bakalari'),
          trailing: LoginStatusIcon(
            provider: bakaLoginProvider,
            showProvider: useBakaProvider,
          ),
        ),
        SettingTile(
          heroTag: 'strava',
          title: loc.stravaCz,
          leading: const Icon(Icons.restaurant_outlined),
          onTap: (context) => Navigator.restorablePushNamed(context, '/strava'),
          trailing: LoginStatusIcon(
            provider: stravaLoginProvider,
            showProvider: useMealsProvider,
          ),
        ),
        SettingTile(
          heroTag: 'cloudsync',
          title: loc.cloudSync,
          isLast: true,
          leading: const Icon(Icons.cloud_outlined),
          onTap: (context) =>
              Navigator.restorablePushNamed(context, '/cloudsync'),
          trailing: LoginStatusIcon(
            provider: firebaseLoginProvider,
            showProvider: useCloudSyncProvider,
          ),
        ),
        SettingTile(
          heroTag: 'about',
          isFirst: true,
          title: context.loc.aboutApp,
          leading: const Icon(Icons.info_outline_rounded),
          onTap: (context) => Navigator.restorablePushNamed(context, '/about'),
        ),
        SettingTile(
          isLast: !(debugMode || kDebugMode),
          title: context.loc.appDataLabel,
          trailing: const ImportExportButtonsRow(),
        ),
        if (debugMode || kDebugMode)
          SettingTile.withSwitch(
            isLast: true,
            leading: const Icon(Icons.bug_report_outlined),
            title: loc.developerMode,
            value: debugMode,
            onChanged: (value) {
              ref.read(debugModeProvider.notifier).set(value);
            },
          ),
        if (debugMode)
          Center(
            child: Text(
              packageInfo.packageName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        const Center(
          child: PackageInfoWidget(enableTap: true),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
