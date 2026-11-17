// ignore_for_file: deprecated_member_use

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:schoolarc/features/timetable/presentation/actual_timetable_screen.dart';
import 'package:schoolarc/features/timetable/presentation/timetable_screen.dart';
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
import 'package:schoolarc/screens/onboarding/privacy_policy.dart';
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
import 'package:schoolarc/screens/tutorial/tutorial.dart';
import 'package:schoolarc/utils/extensions/color_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';
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
        width: 124,
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
    final deviceContrast = MediaQuery.highContrastOf(context);
    final appThemeLight = ColorScheme.fromSeed(
      seedColor: defaultColor,
      brightness: Brightness.light,
      contrastLevel: deviceContrast ? 1 : 0,
      dynamicSchemeVariant: DynamicSchemeVariant.values[dynamicSchemeVariant],
    );
    final appThemeDark = ColorScheme.fromSeed(
      seedColor: defaultColor,
      brightness: Brightness.dark,
      contrastLevel: deviceContrast ? 1 : 0,
      dynamicSchemeVariant: DynamicSchemeVariant.values[dynamicSchemeVariant],
    );

    return DynamicColorBuilder(
      builder: (deviceLight, deviceDark) {
        late ColorScheme light, dark;
        if (useDeviceColor && deviceLight != null && deviceDark != null) {
          light = deviceLight;
          dark = deviceDark;
        } else {
          light = appThemeLight;
          dark = appThemeDark;
        }

        if (useOled) {
          dark = dark.copyWith(
            surface: Colors.black,
            surfaceContainer: Colors.black,
            surfaceContainerLow: dark.surfaceContainerLow.darken(0.05),
            surfaceContainerHigh: dark.surfaceContainerHigh.darken(0.05),
            surfaceContainerHighest: dark.surfaceContainerHighest.darken(0.05),
            surfaceContainerLowest: dark.surfaceContainerLowest.darken(0.02),
          );
        }

        // dark = ColorScheme.fromSeed(seedColor: Colors.green);

        return MaterialApp(
          restorationScopeId: 'root',
          navigatorObservers: [PosthogObserver()],
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
            // TODO splash
            // splashFactory: NewInkSparkle.splashFactory,
            listTileTheme: const ListTileThemeData(
              dense: true,
              visualDensity: VisualDensity.compact,
            ),
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
            // TODO splash
            // splashFactory: NewInkSparkle.splashFactory,
            listTileTheme: const ListTileThemeData(
              dense: true,
              visualDensity: VisualDensity.compact,
            ),
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
            '/privacy': (context) => const PrivacyPolicy(),
          },
        );
      },
    );
  }
}
