import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/database/settings_database.dart';
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

class StyleMotionPage extends ConsumerStatefulWidget {
  const StyleMotionPage({super.key});

  @override
  ConsumerState<StyleMotionPage> createState() => _StyleMotionPageState();
}

class _StyleMotionPageState extends ConsumerState<StyleMotionPage> {
  late final nameController = TextEditingController(
    text: ref.read(usernameProvider),
  );
  bool isFetchingName = false;

  @override
  void initState() {
    nameController.addListener(
      () {
        ref
            .read(usernameProvider.notifier)
            .updateNameManually(nameController.text);
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final showMyName = ref.watch(greetUsernameProvider);
    final name = ref.watch(usernameProvider);
    final lunchTime = ref.watch(mealsShowTodayUntilProvider);
    final showMissed = ref.watch(calendarShowMissedProvider);
    final showArrows = ref.watch(calendarShowArrowsProvider);
    final showWholeWeek = ref.watch(timeTableShowWholeWeekProvider);
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
          enabled: !isFetchingName,
          title: context.loc.myName,
          subtitle: context.loc.myNameDescription,
          leading: isFetchingName
              ? const SizedBox(
                  height: 56,
                  width: 48,
                  child: M3ELoadingIndicator(),
                )
              : null,
          value: name,
          controller: nameController,
          trailing: M3EIconButton(
            enabled: !isFetchingName,
            style: .tonal,
            onPressed: () {
              final manuallySet = ref
                  .read(usernameProvider.notifier)
                  .manuallySet;
              // TODO only show this if the username CAN be loaded from bakalari and maybe instead of loading the name just show Loaded from bakalari: David. Set name to David? -> yes
              showMyDialog(
                context: context,
                title: manuallySet
                    ? context.loc.nameSetManuallyTitle
                    : context.loc.nameFetchedTitle,
                content: !manuallySet
                    ? Text(context.loc.nameFetchedText)
                    : Column(
                        crossAxisAlignment: .start,
                        mainAxisSize: .min,
                        children: [
                          Text('You have set your name to $name.'),
                          const Divider(),
                          const Text(
                            'Your name can also be loaded from Bakalari. This will override your current name.',
                          ),
                          M3EFilledButton.tonal(
                            onPressed: () async {
                              Navigator.pop(context);
                              setState(() {
                                isFetchingName = true;
                              });
                              try {
                                setState(() {
                                  isFetchingName = true;
                                });
                                final fetchedName = await ref
                                    .read(usernameProvider.notifier)
                                    .disableNameManuallySet();
                                if (!context.mounted) return;
                                setState(() {
                                  isFetchingName = false;
                                });

                                if (fetchedName != null) {
                                  nameController.text = fetchedName;
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                showErrorMessage(context, e);
                                return;
                              }
                            },
                            child: const Text('Load name from Bakalari'),
                          ),
                          const Divider(),
                        ],
                      ),
                actions: [
                  DialogActionButton(
                    text: context.loc.ok,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
            icon: const Icon(Icons.info_outline_rounded),
          ),
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
        SettingTextDivider(text: loc.timetable),
        SettingTile.withSwitch(
          isFirst: true,
          isLast: true,
          title: loc.show7DayWeek,
          // subtitle: loc.showArrowsSubtitle,
          value: showWholeWeek,
          onChanged: (value) {
            ref.read(timeTableShowWholeWeekProvider.notifier).set(value);
          },
        ),
      ],
    );
  }
}
