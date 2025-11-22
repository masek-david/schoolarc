import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/provider/locale_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/drop_down_action.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';

class LocalizationPage extends ConsumerWidget {
  const LocalizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime(2025, 1, 31, 20, 45);
    final loc = context.loc;
    final use24HourFormat = ref.watch(use24HourFormatProvider);
    final language = ref.watch(localeProvider).languageCode;
    final dateFormat = ref.watch(dateFormatProvider);
    final weekStartsOnMonday = ref.watch(weekStartsOnMondayProvider);

    return SettingsScaffold(
      heroTag: 'localizations',
      title: loc.localization,
      children: [
        SettingTile(
          isFirst: true,
          title: loc.language,
          trailing: DropDownAction(
            value: language,
            onChanged: (value) {
              ref.read(localeProvider.notifier).set(value as String);
            },
            items: supportedLocales
                .map(
                  (key, value) => MapEntry(
                    key,
                    DropdownMenuItem<String>(
                      value: key.languageCode,
                      child: Text(value),
                    ),
                  ),
                )
                .values
                .toList(),
          ),
        ),
        SettingTile(
          title: loc.dateFormat,
          subtitle: '${loc.today}: ${Date.today().formatFromSettings()}',
          trailing: DropDownAction(
            value: dateFormat,
            onChanged: (value) {
              ref.read(dateFormatProvider.notifier).set(value as String);
            },
            items: supportedDateFormats
                .map(
                  (value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      DateFormat(value, getLocale().languageCode).format(date),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        // show setting for 24 hour format only if it is supported
        if (DateFormat.jm(language).format(date).contains('PM'))
          SettingTile.withSwitch(
            title: loc.timeFormat,
            value: use24HourFormat,
            subtitle: '''
${loc.timeFormatSubtitle}
${loc.now}: ${TimeOfDay.now().format(context)}''',
            onChanged: (value) =>
                ref.read(use24HourFormatProvider.notifier).set(value),
          ),
        SettingTile.withSwitch(
          isLast: true,
          title: loc.weekStartsOnMonday,
          subtitle: loc.weekStartsOnMondaySubtitle,
          value: weekStartsOnMonday,
          onChanged: (value) {
            ref.read(weekStartsOnMondayProvider.notifier).set(value);
          },
        ),
      ],
    );
  }
}
