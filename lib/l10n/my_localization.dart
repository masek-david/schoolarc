import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schoolarc/l10n/app_localizations.dart';
import 'package:schoolarc/utils/globals.dart';

final supportedLocales = {
  const Locale('en'): 'English',
  const Locale('cs'): 'Čeština',
};

const supportedDateFormats = [
  null,
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
  null,
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


AppLocalizations getLocalizationWithoutContext() {
  return lookupAppLocalizations(_getLocale());
}

/// returns current supported locale, if it isnt set, it uses devices locale, if it isnt supported, it returns 'en' locale
Locale _getLocale() {
  Locale? locale;
  final localLanguageCode = settings.get(.languageCode) as String?;

  if (localLanguageCode != null) {
    locale = Locale(localLanguageCode);
  } else if (!kIsWeb) {
    final platform = Platform.localeName.split('_');
    locale = Locale(platform[0]);
  }

  if (!supportedLocales.keys.contains(locale) || locale == null) {
    locale = const Locale('en');
  }

  return locale;
}
