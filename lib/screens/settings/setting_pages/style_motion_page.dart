import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/initial_app_page.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/settings/widgets/slider_action.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class StyleMotionPage extends ConsumerWidget {
  const StyleMotionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsScaffold(
      heroTag: 'style',
      title: context.loc.styleMotion,
      children: [
        SettingTile(
          isFirst: true,
          title: context.loc.initialPageTitle,
          subtitle: context.loc.initialPageSubtitle,
          newLineAction: const InitialAppPage(),
        ),
        SettingTile(
          isLast: true,
          title: context.loc.styleMotionScreenSwitchAnimationTitle,
          subtitle: context.loc.styleMotionScreenSwitchAnimationSubtitle,
          leading: const Icon(Icons.timelapse),
          newLineAction: SliderAction(
            inititalValue: settings.get(Setting.pageSwitchAnimationDuration),
            divisions: 10,
            min: 0,
            max: 500,
            onChanged: (value) {
              settings.save(Setting.pageSwitchAnimationDuration, value);
            },
          ),
        ),
      ],
    );
  }
}
