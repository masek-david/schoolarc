import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/utils/globals.dart';

final useMealsProvider = settingProvider<bool>(Setting.useMeals);
final useBakaProvider = settingProvider<bool>(Setting.useBakalari);
final useCloudSyncProvider = settingProvider<bool>(Setting.useCloudSync);

final debugModeProvider = settingProvider<bool>(Setting.debugMode);

final use24HourFormatProvider = settingProvider<bool>(Setting.use24HourFormat);

final greetUsernameProvider = settingProvider<bool>(Setting.greetUsername);
final mealsShowTodayUntilProvider =
    settingProvider<TimeOfDay>(Setting.mealsShowTodayUntil);

final calendarInitialIsTomorrowProvider =
    settingProvider<bool>(Setting.calendarInitialIsTomorrow);
final calendarShowMissedProvider =
    settingProvider<bool>(Setting.calendarShowMissed);
final calendarShowArrowsProvider =
    settingProvider<bool>(Setting.calendarShowArrows);

final themeDynamicSchemeVariantProvider =
    settingProvider<int>(Setting.themeDynamicSchemeVariantInt);
final themeColorValueProvider = settingProvider<int>(Setting.themeColorValue);
final themeModeProvider = settingProvider<bool?>(Setting.themeMode);
final themeUseDeviceColorProvider =
    settingProvider<bool>(Setting.themeUseDeviceColor);
final themeUseOledProvider = settingProvider<bool>(Setting.themeUseOled);
final themeExpressiveHapticsProvider = settingProvider<bool>(Setting.useExpressiveHaptics);

final debugShowFireOverlayProvider =
    settingProvider<bool>(Setting.debugShowFireOverlay);
final debugShowPerformanceOverlayProvider =
    settingProvider<bool>(Setting.debugShowPerformanceOverlay);

final weekStartsOnMondayProvider =
    settingProvider<bool>(Setting.weekStartsOnMonday);
final dateFormatProvider = settingProvider<String?>(Setting.dateFormat);

NotifierProvider<SettingNotifier<T>, T> settingProvider<T>(Setting setting) {
  return NotifierProvider<SettingNotifier<T>, T>(
    () => SettingNotifier<T>(setting),
  );
}

class SettingNotifier<T> extends Notifier<T> {
  final Setting setting;

  SettingNotifier(this.setting);

  @override
  T build() {
    return settings.get(setting);
  }

  void set(T value) {
    settings.save(setting, value);
    state = value;
  }
}
