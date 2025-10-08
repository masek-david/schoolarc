import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/utils/globals.dart';

/// Knows about app settings and locale
extension BetterDate on Date{
  /// Formats using saved DateTime format and using apps language, but if the year is the
  /// same as the current and isn't forced with [forceShowYear], doesn't include it
  String formatFromSettings({bool forceShowYear = false}) {
    String settingsFormat = settings.get(Setting.dateFormat);

    final dateFormat = (year == Date.today().year && !forceShowYear)
        ? supportedDateFormatsNoYear[supportedDateFormats.indexOf(settingsFormat)]
        : settingsFormat;

    return format(dateFormat, getLocale().languageCode);
  }

    /// Will try to return Yesterday, Today or Tomorrow, if not possible, will use [formatFromSettings]
  String formatWithText({bool forceShowYear = false}) {
    final today = Date.today();
    final loc = getLocalization();

    if (isSameDay(today)) {
      return loc.today;
    }
    if (isSameDay(today.addDays(1))) {
      return loc.tomorrow;
    }
    if (isSameDay(today.subtractDays(1))) {
      return loc.yesterday;
    }
    return formatFromSettings();
  }
} 