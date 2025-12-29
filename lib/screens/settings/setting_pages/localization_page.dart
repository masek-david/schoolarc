import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/provider/language_code_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/drop_down_action.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/services/home_widget_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class LocalizationPage extends ConsumerWidget {
  const LocalizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.now();
    final loc = context.loc;
    final use24HourFormat = ref.watch(use24HourFormatProvider);
    final language = ref.watch(languageCodeProvider);
    final dateFormat = ref.watch(dateFormatProvider);
    final weekStartsOnMonday = ref.watch(weekStartsOnMondayProvider);

    final dropDownItems = supportedLocales
        .map(
          (key, value) => MapEntry(
            key,
            DropdownMenuItem<String?>(
              value: key.languageCode,
              child: Text(value),
            ),
          ),
        )
        .values
        .toList();

    dropDownItems.insert(
      0,
      DropdownMenuItem<String?>(
        value: null,
        child: Text(context.loc.deviceLanguage),
      ),
    );

    return SettingsScaffold(
      heroTag: 'localizations',
      title: loc.localization,
      children: [
        SettingTile(
          isFirst: true,
          title: loc.language,
          subtitle: supportedLocales[Localizations.localeOf(context)],
          trailing: DropDownAction(
            value: language,
            onChanged: (value) {
              vibrate.light();
              saveLocalizationStrings(context);
              ref.read(languageCodeProvider.notifier).set(value);
            },
            items: dropDownItems,
          ),
        ),
        SettingTile(
          title: loc.dateFormat,
          subtitle: '${loc.today}: ${Date.today().formatFromSettings(context)}',
          trailing: DropDownAction(
            value: dateFormat,
            onChanged: (value) {
              vibrate.light();
              ref.read(dateFormatProvider.notifier).set(value);
            },
            items: supportedDateFormats
                .map(
                  (value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value == null
                          ? context.loc.languageDefault
                          : DateFormat(
                              value,
                              context.locale.languageCode,
                            ).format(date),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        // show setting for 24 hour format only if it is supported
        if (DateFormat.jm(
          context.locale.languageCode,
        ).format(DateTime(2017, 9, 7, 17, 30)).contains('PM'))
          SettingTile.withSwitch(
            title: loc.h24timeFormat,
            value: use24HourFormat,
            subtitle:
                '''
${loc.h24timeFormatSubtitle}
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
