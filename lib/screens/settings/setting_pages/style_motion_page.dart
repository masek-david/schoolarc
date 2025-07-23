import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/provider/settings_notifiers.dart';
import 'package:school_manager/screens/settings/widgets/initial_app_page.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/slider_action.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/globals.dart';

class StyleMotionPage extends ConsumerWidget {
  const StyleMotionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAppBorders = ref.watch(showAppBordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.styleMotion),
      ),
      body: ListView(
        children: [
          const InitialAppPage(),
          SettingTile(
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
          SettingTile.withSwitch(
            title: context.loc.styleMotionShowBorderTitle,
            subtitle: context.loc.styleMotionShowBorderSubtitle,
            value: showAppBorders,
            onChanged: (value) {
              ref.read(showAppBordersProvider.notifier).set(value);
            },
          ),
        ],
      ),
    );
  }
}
