import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/l10n/my_localization.dart';
import 'package:school_manager/provider/locale_notifier.dart';
import 'package:school_manager/provider/settings_notifiers.dart';
import 'package:school_manager/screens/settings/widgets/drop_down_action.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/utils/globals.dart';

class LocalizationPage extends ConsumerStatefulWidget {
  const LocalizationPage({super.key});

  @override
  ConsumerState<LocalizationPage> createState() => _LocalizationPageState();
}

class _LocalizationPageState extends ConsumerState<LocalizationPage> {
  String dateFormat = settings.get(Setting.dateFormat);
  bool weekStartsOnMonday = settings.get(Setting.weekStartsOnMonday);
  final date = DateTime(2025, 1, 31, 20, 45);

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    bool use24HourFormat = ref.watch(use24HourFormatProvider);
    final language = ref.watch(localeProvider).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.localization),
      ),
      body: ListView(
        children: [
          SettingTile(
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
            subtitle: '${loc.today}: ${DateTime.now().format()}',
            trailing: DropDownAction(
              value: dateFormat,
              onChanged: (value) {
                settings.save(Setting.dateFormat, value as String);
                setState(() {
                  dateFormat = value;
                });
              },
              items: supportedDateFormats
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        DateFormat(value, getLocale().languageCode)
                            .format(date),
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
            title: loc.weekStartsOnMonday,
            subtitle: loc.weekStartsOnMondaySubtitle,
            value: weekStartsOnMonday,
            onChanged: (value) {
              settings.save(Setting.weekStartsOnMonday, value);
              setState(() {
                weekStartsOnMonday = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
