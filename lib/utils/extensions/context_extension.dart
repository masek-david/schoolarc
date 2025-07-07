import 'package:flutter/material.dart';
import 'package:school_manager/l10n/app_localizations.dart';

extension ContextExtension on BuildContext {
  ColorScheme get col => Theme.of(this).colorScheme;
  TextTheme get txt => Theme.of(this).textTheme;
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
