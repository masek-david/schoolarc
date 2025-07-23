import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/l10n/my_localization.dart';
import 'package:school_manager/utils/globals.dart';

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    return getLocale();
  }

  void set(String code) {
    settings.save(Setting.localeLanguage, code);
    state = Locale(code);
  }
}
