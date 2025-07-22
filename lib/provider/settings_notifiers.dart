import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

final useMealsProvider = settingProvider<bool>(Setting.useMeals);
final useBakaProvider = settingProvider<bool>(Setting.useBakalari);

final debugModeProvider = settingProvider<bool>(Setting.debugMode);

final use24HourFormatProvider = settingProvider<bool>(Setting.use24HourFormat);



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
