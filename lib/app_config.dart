// ignore_for_file: deprecated_member_use

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/l10n/app_localizations.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/main_app.dart';
import 'package:schoolarc/provider/locale_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/bakalari/baka_homeworks/baka_homeworks_screen.dart';
import 'package:schoolarc/screens/bakalari/bakalari_login_screen.dart';
import 'package:schoolarc/screens/changelog_screen.dart';
import 'package:schoolarc/screens/debug_info_screen.dart';
import 'package:schoolarc/screens/firebase/cloudsync_login_screen.dart';
import 'package:schoolarc/screens/logs/logs_screen.dart';
import 'package:schoolarc/screens/main_screens/calendar/calendar_screen.dart';
import 'package:schoolarc/screens/meals/meals_screen.dart';
import 'package:schoolarc/screens/meals/strava_login_screen.dart';
import 'package:schoolarc/screens/recap/recap_screen.dart';
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
import 'package:schoolarc/screens/timetable/current_timetable_screen.dart';
import 'package:schoolarc/screens/timetable/timetable_screen.dart';
import 'package:schoolarc/utils/extensions/color_extension.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color defaultColor = Color(ref.watch(themeColorValueProvider));
    final dynamicSchemeVariant = ref.watch(themeDynamicSchemeVariantProvider);
    final themeMode = _getThemeMode(ref.watch(themeModeProvider));
    final useOled = ref.watch(themeUseOledProvider);
    final useDeviceColor = ref.watch(themeUseDeviceColorProvider);
    final locale = ref.watch(localeProvider);

    return DynamicColorBuilder(
      builder: (
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
          surfaceContainerLow:
              useOled ? schemes.$2.surfaceContainerLow.darken(0.05) : null,
          surfaceContainerHigh:
              useOled ? schemes.$2.surfaceContainerHigh.darken(0.05) : null,
          surfaceContainerHighest:
              useOled ? schemes.$2.surfaceContainerHighest.darken(0.05) : null,
          surfaceContainerLowest:
              useOled ? schemes.$2.surfaceContainerLowest.darken(0.02) : null,
        );

        return MaterialApp(
          restorationScopeId: 'root',
          navigatorKey: navigatorKey,
          title: 'Schoolarc',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedLocales.keys,
          locale: locale,
          debugShowCheckedModeBanner: false,
          showPerformanceOverlay: ref.watch(debugModeProvider) &&
              ref.watch(debugShowPerformanceOverlayProvider),
          theme: ThemeData(
            colorScheme: light,
            sliderTheme: const SliderThemeData(year2023: false),
            materialTapTargetSize: MaterialTapTargetSize.padded,
            visualDensity: VisualDensity.standard,
            progressIndicatorTheme:
                const ProgressIndicatorThemeData(year2023: false),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              contentPadding: const EdgeInsets.all(15),
              fillColor: light.surfaceContainerLow,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: ButtonStyle(
                side: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.focused)) {
                    return BorderSide(
                      color: light.primary,
                      width: 3,
                      strokeAlign: 3,
                    );
                  }
                  return null;
                }),
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: dark,
            sliderTheme: const SliderThemeData(year2023: false),
            materialTapTargetSize: MaterialTapTargetSize.padded,
            visualDensity: VisualDensity.standard,
            // pageTransitionsTheme: const PageTransitionsTheme(
            //   builders: <TargetPlatform, PageTransitionsBuilder>{
            //     // Set the predictive back transitions for Android.
            //     TargetPlatform.android:
            //         PredictiveBackPageTransitionsBuilder(),
            //   },
            // ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              contentPadding: const EdgeInsets.all(15),
              fillColor: dark.surfaceContainerLow,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: ButtonStyle(
                side: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.focused)) {
                    return BorderSide(
                      color: dark.primary,
                      width: 3,
                      strokeAlign: 3,
                    );
                  }
                  return null;
                }),
              ),
            ),
            progressIndicatorTheme:
                const ProgressIndicatorThemeData(year2023: false),
          ),
          themeMode: themeMode,
          home: const MainApp(),
          builder: (context, child) => TimeFormat(
            child: child ?? const SizedBox.shrink(),
          ),
          onGenerateRoute: (settings) {
            // we have to psuh a route, else it throws
            // we also cant return mainapp, since it throws multiple widgets use the same key
            if (settings.name == '/calendar') {
              navigatorKey.currentState?.popUntil((route) => route.isFirst);
              ref.read(showCalendarProvider.notifier).show();
              closeDrawer();

              return MaterialPageRoute(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context);
                  });
                  return const Scaffold(); // Blank page briefly shown
                },
              );
            }
            return null;
          },
          routes: {
            '/settings': (context) => const SettingsScreen(),
            '/subjects': (context) => const SubjectsScreen(),
            '/timetable': (context) => const TimetableScreen(),
            '/timetable-current': (context) => const CurrentTimetableScreen(),
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
          },
        );
      },
    );
  }
}
