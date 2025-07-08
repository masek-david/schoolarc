import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

final use24HourFormatProvider =
    NotifierProvider<Use24HourFormatNotifier, bool>(Use24HourFormatNotifier.new);

class Use24HourFormatNotifier extends Notifier<bool> {
  @override
  bool build() {
    return settings.get(Setting.use24HourFormat);
  }

  void set(bool value) {
    settings.save(Setting.use24HourFormat, value);

    state = value;
  }
}
