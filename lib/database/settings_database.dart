import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/l10n/my_localization.dart';

/// To define a new setting, create a field in [Setting] enum
/// and then create [SettingModel] in [SettingsDatabase] [_settings]
///
/// To create a provider for this setting, define it inside settings_notifiers.dart

enum Setting {
  themeUseDeviceColor,
  themeColorValue,
  themeDynamicSchemeVariantInt,
  themeUseOled,
  localeLanguage,
  use24HourFormat,
  dateFormat,
  weekStartsOnMonday,
  initialAppPage,
  pageSwitchAnimationDuration,
  showAppOverlay,
  tomorrowNotificationEnabled,
  tomorrowNotificationTime,
  stopAskingForNotifications,
  themeMode,
  timeTableShowWholeWeek,
  timeTableTileWidth,
  bakaKeepLoggedIn,
  calendarInitialIsTomorrow,
  calendarShowMissed,
  calendarResizableContainerRatio,
  calendarShowArrows,
  mealsShowTodayUntil,
  userName,
  greetUsername,
  useMeals,
  allowStravaLogin,
  useBakalari,
  useFirebase,
  debugMode,
  debugShowPerformanceOverlay,
  debugShowFireOverlay,
  recapShownForYear,
  cloudSyncConsent,
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
    Setting.localeLanguage: const SettingModel(
      key: 'localeLanguage',
      // format: 'cs' or 'en'
      defaultValue: null,
    ),
    Setting.use24HourFormat: const SettingModel(
      key: '24HourFormat',
      defaultValue: false,
    ),
    Setting.dateFormat: SettingModel(
      key: 'dateFormat',
      defaultValue: supportedDateFormats[0],
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
      key: 'pageSwitchDuration',
      defaultValue: 0.0,
    ),
    Setting.showAppOverlay: const SettingModel(
      defaultValue: true,
      key: 'showOverlay',
    ),
    Setting.tomorrowNotificationEnabled: const SettingModel(
      defaultValue: true,
      key: 'tomorrowNotificationEnabled',
    ),
    Setting.tomorrowNotificationTime: const SettingModel(
      defaultValue: TimeOfDay(hour: 18, minute: 00),
      key: 'tomorrowNotificationTimeOfDay',
    ),
    Setting.stopAskingForNotifications: const SettingModel(
      defaultValue: null,
      key: 'stopAskingForNotifications',
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
    Setting.bakaKeepLoggedIn: const SettingModel(
      defaultValue: true,
      key: 'bakaKeepLoggedIn',
    ),
    Setting.calendarInitialIsTomorrow: const SettingModel(
      defaultValue: true,
      key: 'calendarInitialIstomorrow',
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
    Setting.useFirebase: const SettingModel(
      defaultValue: false,
      key: 'useFirebase',
    ),
    Setting.debugMode: const SettingModel(
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
    Setting.cloudSyncConsent: const SettingModel(
      defaultValue: false,
      key: 'cloudSyncConsent',
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
    const dbKey = 'firstTimeOpeningApp1';

    if (_settingsBox.get(dbKey) != true) {
      _settingsBox.put(dbKey, true);
      return true;
    } else {
      return false;
    }
  }

  void deleteAllFromDisk(){
    _settingsBox.deleteFromDisk();
  }
}
