import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/settings/widgets/drop_down_action.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class CalendarSettings extends ConsumerWidget {
  const CalendarSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMissed = ref.watch(calendarShowMissedProvider);
    final showArrows = ref.watch(calendarShowArrowsProvider);
    final initialIsTomorrow = ref.watch(calendarInitialIsTomorrowProvider);
    final loc = context.loc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingTile(
          title: loc.initialDate,
          trailing: DropDownAction(
            value: initialIsTomorrow,
            items: [
              DropdownMenuItem(
                value: false,
                child: Text(loc.today),
              ),
              DropdownMenuItem(
                value: true,
                child: Text(loc.tomorrow),
              ),
            ],
            onChanged: (value) {
              ref
                  .read(calendarInitialIsTomorrowProvider.notifier)
                  .set(value as bool);
            },
          ),
        ),
        SettingTile.withSwitch(
          title: loc.showMissedHomework,
          value: showMissed,
          onChanged: (value) {
            ref.read(calendarShowMissedProvider.notifier).set(value);
          },
        ),
        SettingTile.withSwitch(
          title: loc.showArrows,
          subtitle: loc.showArrowsSubtitle,
          value: showArrows,
          onChanged: (value) {
            ref.read(calendarShowArrowsProvider.notifier).set(value);
          },
        ),
      ],
    );
  }
}
