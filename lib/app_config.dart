// ignore_for_file: deprecated_member_use

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/l10n/app_localizations.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/main_app.dart';
import 'package:schoolarc/provider/language_code_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/bakalari/baka_homeworks/baka_homeworks_screen.dart';
import 'package:schoolarc/screens/bakalari/bakalari_login_screen.dart';
import 'package:schoolarc/screens/changelog_screen.dart';
import 'package:schoolarc/screens/debug_info_screen.dart';
import 'package:schoolarc/screens/firebase/cloudsync_login_screen.dart';
import 'package:schoolarc/screens/logs/logs_screen.dart';
import 'package:schoolarc/screens/meals/meals_screen.dart';
import 'package:schoolarc/screens/meals/strava_login_screen.dart';
import 'package:schoolarc/screens/recap/recap_screen.dart';
import 'package:schoolarc/screens/recap/sticker/recap_sticker_screen.dart';
import 'package:schoolarc/screens/recently_deleted_screen.dart';
import 'package:schoolarc/screens/settings/about_app.dart';
import 'package:schoolarc/screens/settings/setting_pages/localization_page.dart';
import 'package:schoolarc/screens/settings/setting_pages/shortcuts_page.dart';
import 'package:schoolarc/screens/settings/setting_pages/style_motion_page.dart';
import 'package:schoolarc/screens/settings/setting_pages/theme_page.dart';
import 'package:schoolarc/screens/settings/setting_pages/tomorrow_notifications_page.dart';
import 'package:schoolarc/screens/settings/settings_screen.dart';
import 'package:schoolarc/screens/shared/group_screen.dart';
import 'package:schoolarc/screens/subjects/subjects_screen.dart';
import 'package:schoolarc/screens/timetable/actual_timetable_screen.dart';
import 'package:schoolarc/screens/timetable/timetable_screen.dart';
import 'package:schoolarc/screens/tutorial/tutorial.dart';
import 'package:schoolarc/utils/extensions/color_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/theme_generate.dart';
import 'package:schoolarc/widgets/config/time_format.dart';

/// defines theme
class AppConfig extends ConsumerWidget {
  const AppConfig({super.key});

  ThemeMode _getThemeMode(bool? value) {
    switch (value) {
      case null:
        return ThemeMode.system;

      case true:
        return ThemeMode.dark;

      case false:
        return ThemeMode.light;
    }
  }

  TextTheme getTextTheme() {
    return TextTheme(
      displayLarge: googleSansFlex(
        size: 57,
        roundness: 100,
        weight: 800,
        width: 131,
        letterSpacing: -2,
      ),
      displayMedium: googleSansFlex(
        size: 45,
        roundness: 100,
        weight: 700,
        width: 131,
        letterSpacing: -1.5,
      ),
      displaySmall: googleSansFlex(
        size: 36,
        roundness: 100,
        weight: 600,
        width: 131,
        letterSpacing: -1,
      ),
      headlineLarge: googleSansFlex(size: 32, roundness: 100, weight: 600),
      headlineMedium: googleSansFlex(size: 28, roundness: 100, weight: 550),
      headlineSmall: googleSansFlex(size: 24, roundness: 100, weight: 500),
      titleLarge: googleSansFlex(size: 22, roundness: 100, weight: 400),
      titleMedium: googleSansFlex(size: 16, roundness: 100, weight: 500),
      titleSmall: googleSansFlex(size: 14, roundness: 100, weight: 450),
      bodyLarge: const TextStyle(fontSize: 16),
      bodyMedium: const TextStyle(fontSize: 14),
      bodySmall: const TextStyle(fontSize: 12),
      labelLarge: googleSansFlex(
        size: 14,
        roundness: 100,
        weight: 500,
        width: 71,
        letterSpacing: 0.5,
      ),
      labelMedium: googleSansFlex(
        size: 12,
        roundness: 100,
        weight: 500,
        width: 81,
      ),
      labelSmall: googleSansFlex(
        size: 11,
        roundness: 100,
        weight: 400,
        width: 91,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color defaultColor = Color(ref.watch(themeColorValueProvider));
    final dynamicSchemeVariant = ref.watch(themeDynamicSchemeVariantProvider);
    final themeMode = _getThemeMode(ref.watch(themeModeProvider));
    final useOled = ref.watch(themeUseOledProvider);
    final useDeviceColor = ref.watch(themeUseDeviceColorProvider);
    final languageCode = ref.watch(languageCodeProvider);
    final locale = languageCode != null ? Locale(languageCode) : null;

    return DynamicColorBuilder(
      builder:
          (
            ColorScheme? deviceLight,
            ColorScheme? deviceDark,
          ) {
            var defaultLight = ColorScheme.fromSeed(
              seedColor: defaultColor,
              brightness: Brightness.light,
              dynamicSchemeVariant:
                  DynamicSchemeVariant.values[dynamicSchemeVariant],
            );
            var defaultDark = ColorScheme.fromSeed(
              seedColor: defaultColor,
              brightness: Brightness.dark,
              dynamicSchemeVariant:
                  DynamicSchemeVariant.values[dynamicSchemeVariant],
            );

            if (useDeviceColor) {
              if (deviceLight != null && deviceDark != null) {
                defaultLight = deviceLight;
                defaultDark = deviceDark;
              }
            }

            (ColorScheme, ColorScheme) schemes = generateDynamicColourSchemes(
              defaultLight,
              defaultDark,
            );

            final light = schemes.$1;
            final dark = schemes.$2.copyWith(
              surface: useOled ? Colors.black : null,
              surfaceContainer: useOled ? Colors.black : null,
              surfaceContainerLow: useOled
                  ? schemes.$2.surfaceContainerLow.darken(0.05)
                  : null,
              surfaceContainerHigh: useOled
                  ? schemes.$2.surfaceContainerHigh.darken(0.05)
                  : null,
              surfaceContainerHighest: useOled
                  ? schemes.$2.surfaceContainerHighest.darken(0.05)
                  : null,
              surfaceContainerLowest: useOled
                  ? schemes.$2.surfaceContainerLowest.darken(0.02)
                  : null,
            );

            return MaterialApp(
              restorationScopeId: 'root',
              navigatorKey: navigatorKey,
              title: 'Schoolarc',
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: supportedLocales.keys,
              locale: locale,
              debugShowCheckedModeBanner: false,
              showPerformanceOverlay:
                  ref.watch(devModeProvider) &&
                  ref.watch(debugShowPerformanceOverlayProvider),
              theme: ThemeData(
                textTheme: getTextTheme(),
                colorScheme: light,
                sliderTheme: const SliderThemeData(year2023: false),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                visualDensity: VisualDensity.standard,
                progressIndicatorTheme: const ProgressIndicatorThemeData(
                  year2023: false,
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  contentPadding: const EdgeInsets.all(15),
                  fillColor: light.surfaceContainer,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              darkTheme: ThemeData(
                textTheme: getTextTheme(),
                colorScheme: dark,
                sliderTheme: const SliderThemeData(year2023: false),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                visualDensity: VisualDensity.standard,
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  contentPadding: const EdgeInsets.all(15),
                  fillColor: dark.surfaceContainer,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                progressIndicatorTheme: const ProgressIndicatorThemeData(
                  year2023: false,
                ),
              ),
              themeMode: themeMode,
              home: const MainApp(),
              builder: (context, child) => TimeFormat(
                child: child ?? const SizedBox.shrink(),
              ),
              routes: {
                '/settings': (context) => const SettingsScreen(),
                '/subjects': (context) => const SubjectsScreen(),
                '/timetable': (context) => const TimetableScreen(),
                '/timetable-actual': (context) => const ActualTimetableScreen(),
                '/bakalari-homeworks': (context) => const BakaHomeworksScreen(),
                '/deleted': (context) => const RecentlyDeletedScreen(),
                '/database': (context) => const DbInfoScreen(),
                '/group': (context) => const GroupScreen(),
                '/meals': (context) => const MealsScreen(),
                '/bakalari': (context) => const BakaLoginScreen(),
                '/strava': (context) => const StravaLoginScreen(),
                '/logs': (context) => const LogsScreen(),
                '/recap': (context) => const RecapScreen(),
                '/cloudsync': (context) => const CloudSyncLoginScreen(),
                '/settings/theme': (context) => const ThemePage(),
                '/settings/style': (context) => const StyleMotionPage(),
                '/settings/notifications': (context) =>
                    const TomorrowNotificationsPage(),
                '/settings/localization': (context) => const LocalizationPage(),
                '/settings/shortcuts': (context) => const ShortcutsPage(),
                '/about': (context) => const AboutApp(),
                '/changelog': (context) => const ChangelogScreen(),
                '/tutorial': (context) => const Tutorial(),
                '/recap-sticker': (context) => const RecapStickerScreen(),
              },
            );
          },
    );
  }
}
