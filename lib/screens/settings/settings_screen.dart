import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/bakalari/baka_login_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_login_notifier.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/import_export_row.dart';
import 'package:schoolarc/screens/settings/widgets/package_info.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/notifications/notification_sender.dart';
import 'package:schoolarc/widgets/baka_imported_icon.dart';
import 'package:schoolarc/widgets/login_status_icon.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = context.loc;
    final devMode = ref.watch(devModeProvider);
    final showFirebaseOverlay = ref.watch(debugShowFireOverlayProvider);
    final showPerformanceOverlay = ref.watch(
      debugShowPerformanceOverlayProvider,
    );

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
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: (context) =>
              Navigator.restorablePushNamed(context, '/settings/theme'),
        ),
        SettingTile(
          heroTag: 'style',
          title: loc.styleMotion,
          subtitle: loc.styleMotionDescription,
          leading: const Icon(Icons.animation_rounded),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: (context) =>
              Navigator.restorablePushNamed(context, '/settings/style'),
        ),
        if (NotificationSender.isCompatiblePlatform() || kDebugMode)
          SettingTile(
            heroTag: 'notifications',
            title: loc.upcomingDayNotifications,
            subtitle: loc.upcomingDayNotificationsDescription,
            leading: const Icon(Icons.notifications_outlined),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: (context) {
              Navigator.restorablePushNamed(
                context,
                '/settings/notifications',
              );
            },
          ),
        SettingTile(
          heroTag: 'localizations',
          title: loc.localization,
          subtitle: loc.localizationSubtitle,
          leading: const Icon(Icons.language_outlined),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: (context) =>
              Navigator.restorablePushNamed(context, '/settings/localization'),
        ),
        SettingTile(
          heroTag: 'shortcuts',
          isLast: true,
          title: loc.shortcuts,
          subtitle: loc.shortcutsDescription,
          leading: const Icon(Icons.keyboard_alt_outlined),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: (context) =>
              Navigator.restorablePushNamed(context, '/settings/shortcuts'),
        ),
        SettingTile(
          heroTag: 'bakalari',
          isFirst: true,
          title: loc.bakalari,
          leading: const BakaImportedIcon(showIcon: false),
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
          leading: const Icon(Icons.restaurant_rounded),
          onTap: (context) => Navigator.restorablePushNamed(context, '/strava'),
          trailing: LoginStatusIcon(
            provider: stravaLoginProvider,
            showProvider: useMealsProvider,
          ),
        ),
        SettingTile(
          heroTag: 'cloudsync',
          title: loc.cloudSync,
          betaTag: true,
          isLast: true,
          leading: const Icon(Icons.cloud_outlined),
          onTap: (context) =>
              Navigator.restorablePushNamed(context, '/cloudsync'),
          trailing: ref.watch(firebaseLoginProvider).value == null
              ? null
              : const Icon(Icons.check_circle_rounded, color: Colors.green),
        ),
        SettingTile(
          heroTag: 'about',
          isFirst: true,
          title: context.loc.aboutApp,
          leading: const Icon(Icons.info_outline_rounded),
          onTap: (context) => Navigator.restorablePushNamed(context, '/about'),
        ),
        SettingTile(
          isLast: true,
          title: context.loc.appDataLabel,
          trailing: const ImportExportButtonsRow(),
        ),
        if (devMode)
          Center(
            child: Text(
              'Schoolarc',
              style: TextStyle(
                color: context.col.surfaceContainerHighest,
              ),
            ),
          ),
        const Center(
          child: PackageInfoWidget(enableTap: true),
        ),
        const SizedBox(height: 16),
        if (devMode || kDebugMode)
          SettingTile.withSwitch(
            isFirst: true,
            isLast: !devMode,
            leading: const Icon(Icons.bug_report_outlined),
            title: loc.developerMode,
            value: devMode,
            onChanged: (value) {
              ref.read(devModeProvider.notifier).set(value);
            },
          ),
        if (devMode)
          SettingTile.withSwitch(
            title: loc.showPerformanceOverlay,
            value: showPerformanceOverlay,
            leading: const Icon(Icons.bug_report_outlined),
            onChanged: (value) {
              ref
                  .read(
                    debugShowPerformanceOverlayProvider.notifier,
                  )
                  .set(value);
            },
          ),
        if (devMode)
          SettingTile.withSwitch(
            title: loc.showFirebaseOverlay,
            value: showFirebaseOverlay,
            leading: const Icon(Icons.bug_report_outlined),
            onChanged: (value) {
              ref.read(debugShowFireOverlayProvider.notifier).set(value);
            },
          ),
        if (devMode)
          SettingTile(
            isLast: true,
            title: loc.viewDatabase,
            leading: const Icon(Icons.data_array_rounded),
            onTap: (context) {
              Navigator.restorablePushNamed(context, '/database');
            },
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}
