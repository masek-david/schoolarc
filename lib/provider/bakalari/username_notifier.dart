import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/provider/bakalari/baka_login_notifier.dart';
import 'package:schoolarc/utils/globals.dart';

final usernameProvider = NotifierProvider<UsernameNotifier, String?>(
  UsernameNotifier.new,
);

class UsernameNotifier extends Notifier<String?> {
  bool manuallySet = false;

  @override
  String? build() {
    _setupListeners();
    try {
      final db = settings.get(Setting.userName);
      manuallySet = settings.get(Setting.userNameManuallySet);
      if (db != null) {
        return db;
      }

      updateNameFromBaka();
    } on Object {
      return null;
    }
    return null;
  }

  /// listen to bakalogin
  void _setupListeners() {
    ref.listen<AsyncValue<bool>>(bakaLoginProvider, (previous, next) {
      next.whenData((value) {
        // fetch only if username isnt set
        if (settings.get(.userName) != '' ||
            settings.get(.userName) != null ||
            settings.get(.userNameManuallySet) == false) {
          return updateNameFromBaka();
        }
      });
    });
  }

  void updateNameManually(String newName) {
    state = newName;
    manuallySet = true;
    settings.save(Setting.userName, newName);
    settings.save(Setting.userNameManuallySet, true);
  }
  
  void disableNameManuallySet() {
    manuallySet = false;
    settings.save(Setting.userNameManuallySet, false);
    updateNameFromBaka();
  }

  Future<void> updateNameFromBaka() async {
    try {
      final isLoggedIn = await ref.read(bakaLoginProvider.future);
      if (!isLoggedIn) return;

      final name = await bakaService.getUsername();
      state = name;
      settings.save(Setting.userName, name);
    } on Object {
      // nothing
    }
  }
}
