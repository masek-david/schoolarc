import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

String getFormatPattern(BuildContext context, bool withoutYear) {
  String? settingsFormat = settings.get(Setting.dateFormat);
  String languageCode = context.locale.languageCode;

  if (settingsFormat == null) {
    if (withoutYear) {
      return DateFormat.Md(languageCode).pattern ?? '';
    }
    return DateFormat.yMd(languageCode).pattern ?? '';
  } else {
    if (withoutYear) {
      return supportedDateFormatsNoYear[supportedDateFormats.indexOf(
        settingsFormat,
      )]!; // is safe, they correspond to each other
    }
    return settingsFormat;
  }
}

/// Knows about app settings and locale
extension BetterDate on Date {
  /// Formats using saved DateTime format or using the apps language if null
  /// if the year is the same as the current and isn't forced with [forceShowYear],
  /// doesn't include year in the format
  String formatFromSettings(
    BuildContext context, {
    bool forceShowYear = false,
  }) {
    String languageCode = context.locale.languageCode;

    String dateFormat = getFormatPattern(
      context,
      (year == Date.today().year && !forceShowYear),
    );

    return format(dateFormat, languageCode);
  }

  String formatMonth(
    BuildContext context, {
    bool forceShowYear = false,
  }) {
    String languageCode = context.locale.languageCode;

    String dateFormat =
        'MMMM ${(year == Date.today().year && !forceShowYear) ? '' : 'yyyy'}';

    return format(dateFormat, languageCode);
  }

  /// Will try to return Yesterday, Today or Tomorrow, if not possible, will use [formatFromSettings]
  String formatWithText(BuildContext context, {bool forceShowYear = false}) {
    final today = Date.today();
    final loc = context.loc;

    if (isSameDay(today)) {
      return loc.today;
    }
    if (isSameDay(today.addDays(1))) {
      return loc.tomorrow;
    }
    if (isSameDay(today.subtractDays(1))) {
      return loc.yesterday;
    }
    return formatFromSettings(context, forceShowYear: forceShowYear);
  }

  /// If difference from today is between 1 and 8, will return name of weekday
  /// Else, will return [formatWithText]
  ///
  /// If [useOnFormat], it will return the form eg. "On Monday"
  String formatWithWeekday(
    BuildContext context, {
    bool useOnFormat = false,
    bool forceShowWeekday = false,
  }) {
    final today = Date.today();
    final diff = difference(today);
    if (diff == 0) {
      return context.loc.today;
    }
    if (diff == 1 && isAfter(today)) {
      return context.loc.tomorrow;
    }

    String formatted = '';

    if (useOnFormat) {
      formatted = context.loc.onWeekday(weekday.toString());
    } else {
      formatted = DateFormat(
        'EEEE',
        context.locale.languageCode,
      ).format(toDateTimeLocal());
    }

    if (forceShowWeekday && diff > 7 && isAfter(today)) {
      formatted += ' ';
      formatted += formatFromSettings(context);
    }

    return formatted;
  }
}
