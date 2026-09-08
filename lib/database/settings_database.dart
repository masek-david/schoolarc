import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:schoolarc/database/hive/hive_init.dart';

/// To define a new setting, create a field in [Setting] enum
/// and then create [SettingModel] in [SettingsDatabase] [_settings]
///
/// To create a provider for this setting, define it inside settings_notifiers.dart
enum Setting {
  themeUseDeviceColor,
  themeColorValue,
  themeDynamicSchemeVariantInt,
  themeUseOled,
  languageCode,
  use24HourFormat,
  dateFormat,
  weekStartsOnMonday,
  initialAppPage,
  pageSwitchAnimationDuration,
  useExpressiveHaptics,
  tomorrowNotificationEnabled,
  tomorrowNotificationTime,
  tomorrowNotificationBeforeWeekend,
  tomorrowNotificationIfEmpty,
  stopAskingForNotifications,
  stopPwaCloudSyncWarning,
  themeMode,
  timeTableShowWholeWeek,
  timeTableTileWidth,

  /// In minutes
  timetablePeriodLastDuration,
  bakaKeepLoggedIn,
  calendarInitialIsTomorrow,
  calendarShowMissed,
  calendarResizableContainerRatio,
  calendarShowArrows,
  mealsShowTodayUntil,
  userName,
  userNameManuallySet,
  greetUsername,
  useMeals,
  allowStravaLogin,
  useBakalari,
  useCloudSync,
  devMode,
  debugShowPerformanceOverlay,
  debugShowFireOverlay,
  recapShownForYear,

  /// the index of the page that was last displayed, null if no page was displayed
  onboardingProgress,
  onboardingIsNewUser,
  requiredBuild,
  lastSeenMessage,
  analyticsEnabled,
}

class SettingModel {
  final String key;
  final dynamic defaultValue;

  const SettingModel({
    required this.key,
    required this.defaultValue,
  });
}

class SettingsDatabase {
  static final Map<Setting, SettingModel> _settings = {
    Setting.themeUseDeviceColor: const SettingModel(
      key: 'themeUseMaterial',
      defaultValue: true,
    ),
    Setting.themeColorValue: SettingModel(
      key: 'themeColor',
      defaultValue: const Color.fromARGB(255, 104, 58, 183).toARGB32(),
    ),
    Setting.themeDynamicSchemeVariantInt: const SettingModel(
      key: 'themeColorMode',
      defaultValue: 7,
    ),
    Setting.themeUseOled: const SettingModel(
      key: 'themeUseOled',
      defaultValue: false,
    ),
    Setting.languageCode: const SettingModel(
      key: 'languageCode',
      // format: 'cs' or 'en', null is for device default
      defaultValue: null,
    ),
    Setting.use24HourFormat: const SettingModel(
      key: '24HourFormat',
      defaultValue: false,
    ),
    Setting.dateFormat: const SettingModel(
      key: 'dateFormat1',
      defaultValue: null,
    ),
    Setting.weekStartsOnMonday: const SettingModel(
      key: 'startOnMonday',
      defaultValue: true,
    ),
    Setting.initialAppPage: const SettingModel(
      key: 'initialAppPage',
      defaultValue: 0,
    ),
    Setting.pageSwitchAnimationDuration: const SettingModel(
      key: 'pageAnimation',
      defaultValue: 250.0,
    ),
    Setting.useExpressiveHaptics: const SettingModel(
      key: 'expressiveHaptics',
      defaultValue: false,
    ),
    Setting.tomorrowNotificationEnabled: const SettingModel(
      defaultValue: true,
      key: 'tomorrowNotificationEnabled',
    ),
    Setting.tomorrowNotificationTime: const SettingModel(
      defaultValue: TimeOfDay(hour: 18, minute: 00),
      key: 'tomorrowNotificationTimeOfDay',
    ),
    Setting.tomorrowNotificationBeforeWeekend: const SettingModel(
      defaultValue: false,
      key: 'tomorrowNotificationBeforeWeekend',
    ),
    Setting.tomorrowNotificationIfEmpty: const SettingModel(
      defaultValue: false,
      key: 'tomorrowNotificationIfEmpty',
    ),
    Setting.stopAskingForNotifications: const SettingModel(
      defaultValue: null,
      key: 'stopAskingForNotifications',
    ),
    Setting.stopPwaCloudSyncWarning: const SettingModel(
      defaultValue: false,
      key: 'stopPwaCloudSyncWarning',
    ),
    Setting.themeMode: const SettingModel(
      defaultValue: null,
      key: 'themeMode',
    ),
    Setting.timeTableShowWholeWeek: const SettingModel(
      defaultValue: false,
      key: 'ttWholeWeek',
    ),
    Setting.timeTableTileWidth: const SettingModel(
      defaultValue: 80.0,
      key: 'ttTileWidth',
    ),
    Setting.timetablePeriodLastDuration: const SettingModel(
      defaultValue: 45,
      key: 'timetablePeriodLastDuration',
    ),
    Setting.bakaKeepLoggedIn: const SettingModel(
      defaultValue: true,
      key: 'bakaKeepLoggedIn',
    ),
    Setting.calendarInitialIsTomorrow: const SettingModel(
      defaultValue: false,
      key: 'calendarInitialIstomorrow1',
    ),
    Setting.calendarShowMissed: const SettingModel(
      defaultValue: true,
      key: 'calendarShowMissed',
    ),
    Setting.calendarResizableContainerRatio: const SettingModel(
      defaultValue: <double>[0.5, 0.5],
      key: 'calendarResizeRatio',
    ),
    Setting.calendarShowArrows: SettingModel(
      defaultValue: kIsWeb || (!Platform.isAndroid && !Platform.isIOS),
      key: 'calendarShowArrows',
    ),
    Setting.mealsShowTodayUntil: const SettingModel(
      defaultValue: TimeOfDay(hour: 14, minute: 30),
      key: 'mealsShowTodayUntilTimeOfDay',
    ),
    Setting.userName: const SettingModel(
      defaultValue: null,
      key: 'userName',
    ),
    Setting.userNameManuallySet: const SettingModel(
      defaultValue: false,
      key: 'userNameManuallySet',
    ),
    Setting.greetUsername: const SettingModel(
      defaultValue: true,
      key: 'homeShowUserName',
    ),
    Setting.useMeals: const SettingModel(
      defaultValue: true,
      key: 'homeShowMeals',
    ),
    Setting.allowStravaLogin: const SettingModel(
      defaultValue: false,
      key: 'allowStravaLogin',
    ),
    Setting.useBakalari: const SettingModel(
      defaultValue: true,
      key: 'homeShowBaka',
    ),
    Setting.useCloudSync: const SettingModel(
      defaultValue: kIsWeb,
      key: 'useFirebase',
    ),
    Setting.devMode: const SettingModel(
      defaultValue: false,
      key: 'showDebug',
    ),
    Setting.debugShowPerformanceOverlay: const SettingModel(
      defaultValue: false,
      key: 'showDebugPerformance',
    ),
    Setting.debugShowFireOverlay: const SettingModel(
      defaultValue: false,
      key: 'showDebugFire',
    ),
    Setting.recapShownForYear: const SettingModel(
      defaultValue: 0,
      key: 'recapShownForYear',
    ),
    Setting.onboardingProgress: const SettingModel(
      defaultValue: null,
      key: 'onboardingProgress',
    ),
    Setting.onboardingIsNewUser: const SettingModel(
      defaultValue: null,
      key: 'onboardingIsNewUser',
    ),
    Setting.requiredBuild: const SettingModel(
      defaultValue: null,
      key: 'requiredBuild',
    ),
    Setting.lastSeenMessage: const SettingModel(
      defaultValue: null,
      key: 'lastSeenMessage',
    ),
    Setting.analyticsEnabled: const SettingModel(
      defaultValue: false,
      key: 'analyticsEnabled',
    ),
  };
  final _settingsBox = Hive.box(settingsBox);

  dynamic get(Setting setting) {
    final SettingModel? settingModel = _settings[setting];
    if (settingModel == null) {
      throw 'No setting found for enum $setting';
    }
    var value = _settingsBox.get(settingModel.key);
    // value = null;

    if (value == null) {
      value = settingModel.defaultValue;
      _settingsBox.put(settingModel.key, value);
    }

    return value;
  }

  void save(Setting setting, dynamic value) {
    final SettingModel? settingModel = _settings[setting];
    if (settingModel == null) {
      throw 'No setting found for enum $setting';
    }

    _settingsBox.put(settingModel.key, value);
  }

  bool get firstTimeOpeningApp {
    const dbKey = 'firstTimeOpeningApp2.2.0';

    if (_settingsBox.get(dbKey) != true) {
      _settingsBox.put(dbKey, true);
      return true;
    } else {
      return false;
    }
  }

  void deleteAllFromDisk() {
    _settingsBox.deleteFromDisk();
  }
}
