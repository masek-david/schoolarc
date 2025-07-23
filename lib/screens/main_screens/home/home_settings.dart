import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/provider/settings_notifiers.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

class HomeSettings extends ConsumerWidget {
  const HomeSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMeals = ref.watch(useMealsProvider);
    final showBaka = ref.watch(useBakaProvider);
    final showMyName = ref.watch(greetUsernameProvider);
    final lunchTime = ref.watch(mealsShowTodayUntilProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingTile.withSwitch(
          title: context.loc.showMyName,
          subtitle: context.loc.showMyNameSubtitle,
          value: showMyName,
          onChanged: (value) {
            ref.read(greetUsernameProvider.notifier).set(value);
          },
        ),
        SettingTile.withSwitch(
          title: context.loc.showBakalariTimetable,
          value: showBaka,
          onChanged: (value) {
            ref.read(useBakaProvider.notifier).set(value);
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
            ref.read(mealsShowTodayUntilProvider.notifier).set(value);
          },
        ),
      ],
    );
  }
}
