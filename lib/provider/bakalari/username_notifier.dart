import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/provider/bakalari/baka_login_notifier.dart';
import 'package:schoolarc/utils/globals.dart';

final usernameProvider =
    NotifierProvider<UsernameNotifier, String?>(UsernameNotifier.new);

class UsernameNotifier extends Notifier<String?> {
  @override
  String? build() {
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

  Future<void> updateName() async {
    try {
      final isLoggedIn = await ref.watch(bakaLoginProvider.future);
      if (!isLoggedIn) {
        return;
      }

      final name = await bakaService.getUsername();
      state = name;
      settings.save(Setting.userName, name);
    } on Object {
      // nothing should happen
    }
  }
}
