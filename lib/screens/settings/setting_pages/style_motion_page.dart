import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/provider/bakalari/username_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/drop_down_action.dart';
import 'package:schoolarc/screens/settings/widgets/initial_app_page.dart';
import 'package:schoolarc/screens/settings/widgets/setting_text_divider.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/settings/widgets/slider_action.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';

class StyleMotionPage extends ConsumerWidget {
  const StyleMotionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMyName = ref.watch(greetUsernameProvider);
    final name = ref.watch(usernameProvider);
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
          leading: const Icon(Icons.timelapse_rounded),
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
        SettingTile.withTextField(
          // This means the widget will update when new name is set in the provider
          key: ValueKey('UsernameTextField:$name'),
          title: context.loc.myName,
          subtitle: context.loc.myNameDescription,
          value: name,
          trailing: IconButtonM3E(
            onPressed: () {
              if (ref.read(usernameProvider.notifier).manuallySet) {
                showMyDialog(
                  context: context,
                  title:context.loc.nameSetManuallyTitle,
                  text:context.loc.nameSetManuallyText(name ?? ''),
                  actions: [
                    DialogActionButton(
                      text: context.loc.cancel,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    DialogActionButton(
                      isDestructiveAction: true,
                      text: context.loc.yes,
                      onPressed: () {
                        ref
                            .read(usernameProvider.notifier)
                            .disableNameManuallySet();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              } else {
                showMyDialog(
                  context: context,
                  title:context.loc.nameFetchedTitle,
                  text:context.loc.nameFetchedText,
                  actions: [
                    DialogActionButton(
                      text: context.loc.ok,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              }
            },
            icon: const Icon(Icons.info_outline_rounded),
          ),
          onSubmitted: (value) {
            ref.read(usernameProvider.notifier).updateNameManually(value);
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
