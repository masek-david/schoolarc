import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/drop_down_action.dart';
import 'package:schoolarc/screens/settings/widgets/initial_app_page.dart';
import 'package:schoolarc/screens/settings/widgets/setting_text_divider.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/settings/widgets/slider_action.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class StyleMotionPage extends ConsumerWidget {
  const StyleMotionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMyName = ref.watch(greetUsernameProvider);
    final lunchTime = ref.watch(mealsShowTodayUntilProvider);
    final showMissed = ref.watch(calendarShowMissedProvider);
    final showArrows = ref.watch(calendarShowArrowsProvider);
    final initialIsTomorrow = ref.watch(calendarInitialIsTomorrowProvider);

    final loc = context.loc;

    return SettingsScaffold(
      heroTag: 'style',
      title: loc.styleMotion,
      children: [
        SettingTile(
          isFirst: true,
          title: loc.initialPageTitle,
          subtitle: loc.initialPageSubtitle,
          newLineAction: const InitialAppPage(),
        ),
        SettingTile(
          title: loc.styleMotionScreenSwitchAnimationTitle,
          subtitle: loc.styleMotionScreenSwitchAnimationSubtitle,
          leading: const Icon(Icons.timelapse),
          newLineAction: SliderAction(
            inititalValue: settings.get(Setting.pageSwitchAnimationDuration),
            divisions: 10,
            min: 0,
            max: 500,
            onChanged: (value) {
              vibrate.selection();
              settings.save(Setting.pageSwitchAnimationDuration, value);
            },
          ),
        ),
        SettingTile.withSwitch(
          value: ref.watch(themeExpressiveHapticsProvider),
          onChanged: ref.read(themeExpressiveHapticsProvider.notifier).set,
          isLast: true,
          title: loc.expressiveHaptics,
          subtitle: loc.expressiveHapticsSub,
          leading: const Icon(Icons.vibration_rounded),
        ),
        SettingTextDivider(text: loc.home),
        SettingTile.withSwitch(
          isFirst: true,
          title: loc.showMyName,
          subtitle: loc.showMyNameSubtitle,
          value: showMyName,
          onChanged: (value) {
            ref.read(greetUsernameProvider.notifier).set(value);
          },
        ),
        SettingTile.withTimePicker(
          isLast: true,
          title: loc.lunchTime,
          subtitle: loc.lunchTimeSubtitle,
          time: lunchTime,
          onChanged: (value) {
            ref.read(mealsShowTodayUntilProvider.notifier).set(value);
          },
        ),
        SettingTextDivider(text: loc.calendar),
        SettingTile(
          isFirst: true,
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
          isLast: true,
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
