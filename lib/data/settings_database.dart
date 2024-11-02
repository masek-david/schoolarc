import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/extensions/timeofday_extension.dart';

enum Setting {
  tommorowNotificationEnabled,
  tommorowNotificationTime,
  themeMode,
  timeTableShowWholeWeek,
  timeTableTileWidth,
  timeTableShowName,
  bakaKeepLoggedIn,
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
    Setting.timeTableShowName: SettingModel(
      defaultValue: false,
      key: 'ttShowName',
    ),
    Setting.bakaKeepLoggedIn: SettingModel(
      defaultValue: false,
      key: 'bakaKeepLoggedIn',
    ),
  };
  final _settingsBox = Hive.box('settings');

  TimeOfDay getTimeOfDay(Setting setting) {
    final SettingModel? settingModel = _settings[setting];
    if (settingModel == null) {
      throw 'No setting found for enum $setting';
    }
    if (settingModel.defaultValue.runtimeType != TimeOfDay){
      throw 'The setting $setting is\'t of type TimeOfDay';
    }

    DateTime? date = _settingsBox.get(settingModel.key);

    if (date == null) {
      date = get(settingModel.defaultValue);
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
