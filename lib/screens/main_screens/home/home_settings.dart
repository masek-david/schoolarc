import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

Future<void> showHomeSettings(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const HomeSettings(),
  );
}

class HomeSettings extends ConsumerWidget {
  const HomeSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMeals = ref.watch(useMealsProvider);
    final showBaka = ref.watch(useBakaProvider);
    final showMyName = ref.watch(greetUsernameProvider);
    final lunchTime = ref.watch(mealsShowTodayUntilProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingTile.withSwitch(
              isFirst: true,
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
              isLast: true,
              title: context.loc.lunchTime,
              subtitle: context.loc.lunchTimeSubtitle,
              time: lunchTime,
              onChanged: (value) {
                ref.read(mealsShowTodayUntilProvider.notifier).set(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
