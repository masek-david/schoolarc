import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/provider/bakalari/baka_login_notifier.dart';
import 'package:schoolarc/utils/globals.dart';

final usernameProvider =
    NotifierProvider<UsernameNotifier, String?>(UsernameNotifier.new);

class UsernameNotifier extends Notifier<String?> {
  @override
  String? build() {
    _setupListeners();
    try {
      final db = settings.get(Setting.userName);
      if (db != null) {
        return db;
      }

      updateName();
    } on Object {
      return null;
    }
    return null;
  }

  /// listen to login
  void _setupListeners() {
    ref.listen<AsyncValue<bool>>(bakaLoginProvider, (previous, next) {
      next.whenData((value) => updateName());
    });
  }

  Future<void> updateName() async {
    try {
      final db = settings.get(Setting.userName);
      if (db != null) return;

      final isLoggedIn = await ref.read(bakaLoginProvider.future);
      if (!isLoggedIn) {
        return;
      }

      final name = await bakaService.getUsername();
      state = name;
      settings.save(Setting.userName, name);
    } on Object {
      // nothing
    }
  }
}
