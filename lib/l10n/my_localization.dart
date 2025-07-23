import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/l10n/app_localizations.dart';
import 'package:schoolarc/utils/globals.dart';

final supportedLocales = {
  const Locale('en'): 'English',
  const Locale('cs'): 'Čeština',
};

const supportedDateFormats = [
  'd. M. yyyy',
  'dd.MM.yyyy',
  'dd/MM/yyyy',
  'dd MMM yyyy',
  'M. d. yyyy',
  'MM.dd.yyyy',
  'MM/dd/yyyy',
  'MMM dd, yyyy',
  'yyyy. M. d',
  'yyyy.MM.dd',
  'yyyy/MM/dd',
  'yyyy MMM dd',
  'yyyy-MM-dd',
];

const supportedDateFormatsNoYear = [
  'd. M.',
  'dd.MM.',
  'dd/MM',
  'dd MMM',
  'M. d.',
  'MM.dd.',
  'MM/dd',
  'MMM dd',
  'M. d',
  'MM.dd',
  'MM/dd',
  'MMM dd',
  'MM-dd',
];

AppLocalizations getLocalization() {
  return lookupAppLocalizations(getLocale());
}

/// returns current locale, if it isnt set, it uses devices locale, if it isnt supported, it returns 'en' locale
Locale getLocale() {
  Locale? locale;
  final localLocaleText = settings.get(Setting.localeLanguage) as String?;

  if (localLocaleText != null) {
    locale = Locale(localLocaleText);
  } else if (!kIsWeb) {
    final platform = Platform.localeName.split('_');
    locale = Locale(platform[0]);
  }

  if (!supportedLocales.keys.contains(locale) || locale == null) {
    locale = const Locale('en');
  }

  return locale;
}
