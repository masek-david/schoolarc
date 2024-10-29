import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/extensions/timeofday_extension.dart';

class DbKeys {
  static Map<String, dynamic> defaultValues = {
    tommorowNotificationEnabled: true,
    tommorowNotificationTime: const TimeOfDay(hour: 18, minute: 00).toDateTime(),
    quickAddEnabled: true,
    quickAddArriveTime: const TimeOfDay(hour: 8, minute: 00).toDateTime(),
    quickAddDissappearTime: const TimeOfDay(hour: 15, minute: 00).toDateTime(),
    quickAddOnWeekends: false,
    themeMode: null,
    timeTableShowWholeWeek: false,
    timeTableTileWidth: 80.0,
    timeTableShowName: false,
    bakaKeepLoggedIn: false,
  };

  static const String appAlreadyOpened = 'appAlreadyOpened';
  static const String tommorowNotificationEnabled =
      'tommorowNotificationEnabled';
  static const String tommorowNotificationTime = 'tommorrowNotificationTime';
  static const String quickAddEnabled = 'quickAddEnabled';
  static const String quickAddArriveTime = 'quickAddArriveTime';
  static const String quickAddDissappearTime = 'quickAddDissappearTime';
  static const String quickAddOnWeekends = 'quickAddOnWeekends';
  static const String themeMode = 'themeMode';
  static const String timeTableShowWholeWeek = 'ttWholeWeek';
  static const String timeTableTileWidth = 'ttTileWidth';
  static const String timeTableShowName = 'ttShowName';
  static const String bakaKeepLoggedIn = 'bakaKeepLoggedIn';
}

class SettingsDatabase {
  final _settingsBox = Hive.box('settings');

  TimeOfDay getTimeOfDay(String key) {
    DateTime? date = _settingsBox.get(key);

    if (date == null) {
      date = DbKeys.defaultValues[key];
      _settingsBox.put(key, date);
    }

    return TimeOfDay.fromDateTime(date!);
  }

  dynamic get(String key) {
    var value = _settingsBox.get(key);

    if (value == null) {
      value = DbKeys.defaultValues[key];
      _settingsBox.put(key, value);
    }

    return value;
  }

  void save(String key, dynamic value) {
    _settingsBox.put(key, value);
  }

  void saveTimeOfDay(String key, TimeOfDay value) {
    _settingsBox.put(key, value.toDateTime());
  }

  bool get firstTimeOpeningApp {
    if (_settingsBox.get(DbKeys.appAlreadyOpened) != true) {
      _settingsBox.put(DbKeys.appAlreadyOpened, true);
      return true;
    } else {
      return false;
    }
  }
}
