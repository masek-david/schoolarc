import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/utils/globals.dart';

final languageCodeProvider = NotifierProvider<LanguageCodeNotifier, String?>(
  LanguageCodeNotifier.new,
);

class LanguageCodeNotifier extends Notifier<String?> {
  @override
  String? build() {
    return settings.get(Setting.languageCode) as String?;
  }

  void set(String? code) {
    state = code;
    settings.save(Setting.languageCode, code);
  }
}
