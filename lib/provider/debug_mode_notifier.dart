import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

final debugModeProvider =
    NotifierProvider<DebugModeNotifier, bool>(DebugModeNotifier.new);

class DebugModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return settings.get(Setting.debugMode);
  }

  void set(bool value) {
    settings.save(Setting.debugMode, value);

    state = value;
  }
}
