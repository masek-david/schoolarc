import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/l10n/my_localization.dart';
import 'package:school_manager/provider/time_format_notifier.dart';
import 'package:school_manager/screens/settings/widgets/drop_down_action.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';

class LocalizationPage extends ConsumerStatefulWidget {
  const LocalizationPage({super.key, required this.refreshTheme});

  final void Function() refreshTheme;

  @override
  ConsumerState<LocalizationPage> createState() => _LocalizationPageState();
}

class _LocalizationPageState extends ConsumerState<LocalizationPage> {
  late String language = getLocale().languageCode;
  String dateFormat = settings.get(Setting.dateFormat);
  bool weekStartsOnMonday = settings.get(Setting.weekStartsOnMonday);
  final date = DateTime(2025, 1, 31, 20, 45);

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    bool? use24HourFormat = ref.watch(timeFormatProvider);

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
                settings.save(Setting.localeLanguage, value as String);
                language = value;
                widget.refreshTheme();
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
            subtitle:
                '${loc.today}: ${DateTime.now().format()}',
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
          SettingTile(
            title: loc.timeFormat,
            subtitle: '${loc.now}: ${TimeOfDay.now().format(context)}',
            trailing: DropDownAction(
              value: use24HourFormat,
              onChanged: (value) =>
                  ref.read(timeFormatProvider.notifier).set(value as bool?),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(loc.defaultWord),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text(loc.timeFormat12),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text(loc.timeFormat24),
                ),
              ],
            ),
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
