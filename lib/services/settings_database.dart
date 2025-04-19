import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:school_manager/utils/extensions/timeofday_extension.dart';

enum Setting {
  themeUseDeviceColor,
  themeColorValue,
  themeDynamicSchemeVariantInt,
  themeUseOled,
  initialAppPage,
  pageSwitchAnimationDuration,
  showAppOverlay,
  tomorrowNotificationEnabled,
  tomorrowNotificationTime,
  themeMode,
  timeTableShowWholeWeek,
  timeTableTileWidth,
  bakaKeepLoggedIn,
  calendarInitialIstomorrow,
  calendarShowMissed,
  calendarResizableContainerRatio,
  mealsShowTodayUntil,
  userName,
  homeShowUserName,
  homeShowMeals,
  homeShowBaka,
  useFirebase,
  showDebugInfo,
  debugShowPerformanceOverlay,
  debugShowFireOverlay,
  expUseHwOverlay,
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
      // ignore: deprecated_member_use
      defaultValue: const Color.fromARGB(255, 104, 58, 183).value,
    ),
    Setting.themeDynamicSchemeVariantInt: SettingModel(
      key: 'themeColorMode',
      defaultValue: 7,
    ),
    Setting.themeUseOled: SettingModel(
      key: 'themeUseOled',
      defaultValue: false,
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
        defaultValue: const TimeOfDay(hour: 18, minute: 00).toInt(),
        key: 'tomorrowNotificationTime'),
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
    Setting.calendarInitialIstomorrow: SettingModel(
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
    Setting.mealsShowTodayUntil: SettingModel(
      defaultValue: const TimeOfDay(hour: 14, minute: 30).toInt(),
      key: 'mealsShowTodayUntil',
    ),
    Setting.userName: SettingModel(
      defaultValue: null,
      key: 'userName',
    ),
    Setting.homeShowUserName: SettingModel(
      defaultValue: true,
      key: 'homeShowUserName',
    ),
    Setting.homeShowMeals: SettingModel(
      defaultValue: true,
      key: 'homeShowMeals',
    ),
    Setting.homeShowBaka: SettingModel(
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
    )
  };
  final _settingsBox = Hive.box('settings');

  TimeOfDay getTimeOfDay(Setting setting) {
    final SettingModel? settingModel = _settings[setting];
    if (settingModel == null) {
      throw 'No setting found for enum $setting';
    }
    if (settingModel.defaultValue.runtimeType != int) {
      throw 'The setting $setting isn\'t of type TimeOfDay';
    }

    int? timeInInt = _settingsBox.get(settingModel.key);

    if (timeInInt == null) {
      timeInInt = get(setting);
      _settingsBox.put(settingModel.key, timeInInt);
    }

    return timeOfDayFromInt(timeInInt!);
  }

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

  void saveTimeOfDay(Setting setting, TimeOfDay value) {
    final SettingModel? settingModel = _settings[setting];
    if (settingModel == null) {
      throw 'No setting found for enum $setting';
    }

    _settingsBox.put(settingModel.key, value.toInt());
  }

  bool get firstTimeOpeningApp {
    const dbKey = 'firstTimeOpeningApp';

    // return true;

    if (_settingsBox.get(dbKey) != true) {
      _settingsBox.put(dbKey, true);
      return true;
    } else {
      return false;
    }
  }
}
