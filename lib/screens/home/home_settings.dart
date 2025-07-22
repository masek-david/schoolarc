import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/provider/settings_notifiers.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

class HomeSettings extends ConsumerStatefulWidget {
  const HomeSettings({
    super.key,
    required this.onChanged,
  });

  final void Function() onChanged;

  @override
  ConsumerState<HomeSettings> createState() => _HomeSettingsState();
}

class _HomeSettingsState extends ConsumerState<HomeSettings> {
  bool showMyName = settings.get(Setting.homeShowUserName);
  bool showBaka = settings.get(Setting.useBakalari);
  TimeOfDay lunchTime = settings.get(Setting.mealsShowTodayUntil);

  @override
  Widget build(BuildContext context) {
    bool showMeals = ref.watch(useMealsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingTile.withSwitch(
          title: context.loc.showMyName,
          subtitle: context.loc.showMyNameSubtitle,
          value: showMyName,
          onChanged: (value) {
            settings.save(Setting.homeShowUserName, value);
            setState(() {
              showMyName = value;
            });
            widget.onChanged();
          },
        ),
        SettingTile.withSwitch(
          title: context.loc.showBakalariTimetable,
          value: showBaka,
          onChanged: (value) {
            settings.save(Setting.useBakalari, value);
            setState(() {
              showBaka = value;
            });
            widget.onChanged();
          },
        ),
        SettingTile.withSwitch(
          title: context.loc.showMeals,
          value: showMeals,
          onChanged: (value) {
            ref.read(useMealsProvider.notifier).set(value);
          },
        ),
        SettingTile.withTimePicker(
          title: context.loc.lunchTime,
          subtitle: context.loc.lunchTimeSubtitle,
          time: lunchTime,
          onChanged: (value) {
            settings.save(Setting.mealsShowTodayUntil, value);
            setState(() {
              lunchTime = value;
            });
            widget.onChanged();
          },
        ),
      ],
    );
  }
}
