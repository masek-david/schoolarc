import 'package:flutter/material.dart';
import 'package:schoolarc/l10n/app_localizations.dart';

extension ContextExtension on BuildContext {
  ColorScheme get col => Theme.of(this).colorScheme;
  TextTheme get txt => Theme.of(this).textTheme;
  AppLocalizations get loc => AppLocalizations.of(this)!;
  Locale get locale => Localizations.localeOf(this);

  bool get isWide => MediaQuery.of(this).size.width > 600;
  bool get isDark => Theme.brightnessOf(this) == Brightness.dark;
}
