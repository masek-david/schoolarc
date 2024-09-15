import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/extensions/timeofday_extension.dart';

class DatabaseKeys {
  static const String appAlreadyOpened = 'appAlreadyOpened';
  static const String tommorowNotificationEnabled =
      'tommorowNotificationEnabled';
  static const String tommorowNotificationTime = 'tommorrowNotificationTime';
  static const String quickAddEnabled = 'quickAddEnabled';
  static const String quickAddArriveTime = 'quickAddArriveTime';
  static const String quickAddDissappearTime = 'quickAddDissappearTime';
  static const String quickAddOnWeekends = 'quickAddOnWeekends';
  static const String themeMode = 'themeMode';
}

class SettingsDatabase {
  final _settingsBox = Hive.box('settings');

  void createInitialData() {
    _settingsBox.putAll({
      DatabaseKeys.tommorowNotificationEnabled: true,
      DatabaseKeys.tommorowNotificationTime: DateTime(1, 1, 1, 18, 00),
      DatabaseKeys.quickAddEnabled: true,
      DatabaseKeys.quickAddArriveTime: DateTime(1, 1, 1, 8, 00),
      DatabaseKeys.quickAddDissappearTime: DateTime(1, 1, 1, 15, 00),
      DatabaseKeys.quickAddOnWeekends: false,
    });
  }

  bool firstTimeOpeningApp() {
    if (_settingsBox.get(DatabaseKeys.appAlreadyOpened) != true) {
      _settingsBox.put(DatabaseKeys.appAlreadyOpened, true);
      return true;
    } else {
      return false;
    }
  }

  // /// ONLY FOR DEBUGGING
  // void setFirstTimeOpeningAppToFalse(){
  //   _settingsBox.put(DatabaseKeys.appAlreadyOpened, false);
  // }

  bool tommorrowNotificationEnabled() {
    return _settingsBox.get(DatabaseKeys.tommorowNotificationEnabled);
  }

  void setTommorowNotificationEnabled(bool value) {
    _settingsBox.put(DatabaseKeys.tommorowNotificationEnabled, value);
  }

  TimeOfDay tommorowNotificationTime() {
    return TimeOfDay.fromDateTime(
        _settingsBox.get(DatabaseKeys.tommorowNotificationTime));
  }

  void setTommorowNotificationTime(TimeOfDay time) {
    // hive doesnt support timeofday by default, so i convert it to datetime
    _settingsBox.put(DatabaseKeys.tommorowNotificationTime, time.toDateTime());
  }

  bool quickAddEnabled() {
    return _settingsBox.get(DatabaseKeys.quickAddEnabled);
  }

  void setQuickAddEnabled(bool value) {
    _settingsBox.put(DatabaseKeys.quickAddEnabled, value);
  }

  TimeOfDay quickAddArriveTime() {
    return TimeOfDay.fromDateTime(
        _settingsBox.get(DatabaseKeys.quickAddArriveTime));
  }

  void setQuickAddArriveTime(TimeOfDay time) {
    _settingsBox.put(DatabaseKeys.quickAddArriveTime, time.toDateTime());
  }

  TimeOfDay quickAddDissappearTime() {
    return TimeOfDay.fromDateTime(
        _settingsBox.get(DatabaseKeys.quickAddDissappearTime));
  }

  void setQuickAddDissappearTime(TimeOfDay time) {
    _settingsBox.put(DatabaseKeys.quickAddDissappearTime, time.toDateTime());
  }

  bool quickAddOnWeekends() {
    return _settingsBox.get(DatabaseKeys.quickAddOnWeekends);
  }

  void setQuickAddOnWeekends(bool value) {
    _settingsBox.put(DatabaseKeys.quickAddOnWeekends, value);
  }

  /// returns true for dark mode, false for light and null for system mode
  bool? themeMode(){
    return _settingsBox.get(DatabaseKeys.themeMode);
  }

  /// sets true for dark mode, false for light and null for system mode
  void setThemeMode(bool? value){
    _settingsBox.put(DatabaseKeys.themeMode, value);
  }
}
