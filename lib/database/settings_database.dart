import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:school_manager/database/hive/hive_init.dart';
import 'package:school_manager/l10n/my_localization.dart';

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
  homeShowUserName,
  useMeals,
  allowStravaLogin,
  useBakalari,
  useFirebase,
  showDebugInfo,
  debugShowPerformanceOverlay,
  debugShowFireOverlay,
  expUseHwOverlay,
  recapShownForYear,
}

class SettingModel {
  final String key;
  final dynamic defaultValue;

  SettingModel({
    required this.key,
    required this.defaultValue,
  });
}

class SettingsDatabase {
  static final Map<Setting, SettingModel> _settings = {
    Setting.themeUseDeviceColor: SettingModel(
      key: 'themeUseMaterial',
      defaultValue: true,
    ),
    Setting.themeColorValue: SettingModel(
      key: 'themeColor',
      defaultValue: const Color.fromARGB(255, 104, 58, 183).toARGB32(),
    ),
    Setting.themeDynamicSchemeVariantInt: SettingModel(
      key: 'themeColorMode',
      defaultValue: 7,
    ),
    Setting.themeUseOled: SettingModel(
      key: 'themeUseOled',
      defaultValue: false,
    ),
    Setting.localeLanguage: SettingModel(
      key: 'localeLanguage',
      // format: 'cs' or 'en'
      defaultValue: null,
    ),
    Setting.use24HourFormat: SettingModel(
      key: '24HourFormat',
      defaultValue: false,
    ),
    Setting.dateFormat: SettingModel(
      key: 'dateFormat',
      defaultValue: supportedDateFormats[0],
    ),
    Setting.weekStartsOnMonday: SettingModel(
      key: 'startOnMonday',
      defaultValue: true,
    ),
    Setting.initialAppPage: SettingModel(
      key: 'initialAppPage',
      defaultValue: 0,
    ),
    Setting.pageSwitchAnimationDuration: SettingModel(
      key: 'pageSwitchDuration',
      defaultValue: 0.0,
    ),
    Setting.showAppOverlay: SettingModel(
      defaultValue: true,
      key: 'showOverlay',
    ),
    Setting.tomorrowNotificationEnabled: SettingModel(
      defaultValue: true,
      key: 'tomorrowNotificationEnabled',
    ),
    Setting.tomorrowNotificationTime: SettingModel(
      defaultValue: const TimeOfDay(hour: 18, minute: 00),
      key: 'tomorrowNotificationTimeOfDay',
    ),
    Setting.stopAskingForNotifications: SettingModel(
      defaultValue: null,
      key: 'stopAskingForNotifications',
    ),
    Setting.themeMode: SettingModel(
      defaultValue: null,
      key: 'themeMode',
    ),
    Setting.timeTableShowWholeWeek: SettingModel(
      defaultValue: false,
      key: 'ttWholeWeek',
    ),
    Setting.timeTableTileWidth: SettingModel(
      defaultValue: 80.0,
      key: 'ttTileWidth',
    ),
    Setting.bakaKeepLoggedIn: SettingModel(
      defaultValue: true,
      key: 'bakaKeepLoggedIn',
    ),
    Setting.calendarInitialIsTomorrow: SettingModel(
      defaultValue: true,
      key: 'calendarInitialIstomorrow',
    ),
    Setting.calendarShowMissed: SettingModel(
      defaultValue: true,
      key: 'calendarShowMissed',
    ),
    Setting.calendarResizableContainerRatio: SettingModel(
      defaultValue: <double>[0.5, 0.5],
      key: 'calendarResizeRatio',
    ),
    Setting.calendarShowArrows: SettingModel(
      defaultValue: kIsWeb || (!Platform.isAndroid && !Platform.isIOS),
      key: 'calendarShowArrows',
    ),
    Setting.mealsShowTodayUntil: SettingModel(
      defaultValue: const TimeOfDay(hour: 14, minute: 30),
      key: 'mealsShowTodayUntilTimeOfDay',
    ),
    Setting.userName: SettingModel(
      defaultValue: null,
      key: 'userName',
    ),
    Setting.homeShowUserName: SettingModel(
      defaultValue: true,
      key: 'homeShowUserName',
    ),
    Setting.useMeals: SettingModel(
      defaultValue: true,
      key: 'homeShowMeals',
    ),
    Setting.allowStravaLogin: SettingModel(
      defaultValue: false,
      key: 'allowStravaLogin',
    ),
    Setting.useBakalari: SettingModel(
      defaultValue: true,
      key: 'homeShowBaka',
    ),
    Setting.useFirebase: SettingModel(
      defaultValue: false,
      key: 'useFirebase',
    ),
    Setting.showDebugInfo: SettingModel(
      defaultValue: false,
      key: 'showDebug',
    ),
    Setting.debugShowPerformanceOverlay: SettingModel(
      defaultValue: false,
      key: 'showDebugPerformance',
    ),
    Setting.debugShowFireOverlay: SettingModel(
      defaultValue: false,
      key: 'showDebugFire',
    ),
    Setting.expUseHwOverlay: SettingModel(
      defaultValue: false,
      key: 'expHwOverlay',
    ),
    Setting.recapShownForYear: SettingModel(
      defaultValue: 0,
      key: 'recapShownForYear',
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
}
