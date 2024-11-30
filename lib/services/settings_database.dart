import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/utils/extensions/timeofday_extension.dart';

enum Setting {
  initialAppPage,
  pageSwitchAnimationDuration,
  tommorowNotificationEnabled,
  tommorowNotificationTime,
  themeMode,
  timeTableShowWholeWeek,
  timeTableTileWidth,
  bakaKeepLoggedIn,
  calendarInitialIsTommorrow,
  calendarShowMissed,
  showDebugInfo,
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
    Setting.initialAppPage: SettingModel(
      key: 'initialAppPage',
      defaultValue: 1,
    ),
    Setting.pageSwitchAnimationDuration: SettingModel(
      key: 'pageSwitchDuration',
      defaultValue: 200.0,
    ),
    Setting.tommorowNotificationEnabled: SettingModel(
      defaultValue: true,
      key: 'tommorowNotificationEnabled',
    ),
    Setting.tommorowNotificationTime: SettingModel(
        defaultValue: const TimeOfDay(hour: 18, minute: 00).toDateTime(),
        key: 'tommorrowNotificationTime'),
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
      defaultValue: false,
      key: 'bakaKeepLoggedIn',
    ),
    Setting.calendarInitialIsTommorrow: SettingModel(
      defaultValue: true,
      key: 'calendarInitialIsTommorrow',
    ),
    Setting.calendarShowMissed: SettingModel(
      defaultValue: true,
      key: 'calendarShowMissed',
    ),
    Setting.showDebugInfo: SettingModel(
      defaultValue: false,
      key: 'showDebug',
    ),
  };
  final _settingsBox = Hive.box('settings');

  TimeOfDay getTimeOfDay(Setting setting) {
    final SettingModel? settingModel = _settings[setting];
    if (settingModel == null) {
      throw 'No setting found for enum $setting';
    }
    if (settingModel.defaultValue.runtimeType != DateTime) {
      throw 'The setting $setting is\'t of type TimeOfDay';
    }

    DateTime? date = _settingsBox.get(settingModel.key);

    if (date == null) {
      date = get(setting);
      _settingsBox.put(settingModel.key, date);
    }

    return TimeOfDay.fromDateTime(date!);
  }

  dynamic get(Setting setting) {
    final SettingModel? settingModel = _settings[setting];
    if (settingModel == null) {
      throw 'No setting found for enum $setting';
    }
    var value = _settingsBox.get(settingModel.key);
    // var value = null;

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

    _settingsBox.put(settingModel.key, value.toDateTime());
  }

  bool get firstTimeOpeningApp {
    const dbKey = 'firstTimeOpeningApp';

    if (_settingsBox.get(dbKey) != true) {
      _settingsBox.put(dbKey, true);
      return true;
    } else {
      return false;
    }
  }
}
