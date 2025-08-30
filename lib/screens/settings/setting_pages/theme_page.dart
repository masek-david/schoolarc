import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/settings/widgets/color_picker_action.dart';
import 'package:schoolarc/screens/settings/widgets/drop_down_action.dart';
import 'package:schoolarc/screens/settings/widgets/scheme_variant_picker_action.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/settings/widgets/theme_colors_showcase.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class ThemePage extends ConsumerWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeUseOled = ref.watch(themeUseOledProvider);
    final useDeviceColor = ref.watch(themeUseDeviceColorProvider);
    final themeMode = ref.watch(themeModeProvider);
    final color = Color(ref.watch(themeColorValueProvider));
    final loc = context.loc;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.themePageTitle),
      ),
      body: ListView(
        children: [
          const ThemeColorsShowcase(),
          SettingTile(
            title: loc.themeBrightness,
            trailing: DropDownAction(
              value: themeMode,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).set(value as bool?);
              },
              items: [
                DropdownMenuItem(
                    value: null, child: Text(loc.themeFollowSystem)),
                DropdownMenuItem(value: false, child: Text(loc.themeLight)),
                DropdownMenuItem(value: true, child: Text(loc.themeDark)),
              ],
            ),
          ),
          if (context.isDark)
            SettingTile.withSwitch(
              title: loc.themeOLEDTitle,
              subtitle: loc.themeOLEDSubtitle,
              value: themeUseOled,
              onChanged: (value) {
                ref.read(themeUseOledProvider.notifier).set(value);
              },
            ),
          SettingTile.withSwitch(
            title: loc.themeUseDeviceColors,
            value: useDeviceColor,
            onChanged: (value) {
              ref.read(themeUseDeviceColorProvider.notifier).set(value);
            },
          ),
          if (useDeviceColor)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                loc.themeSystemColorWarning,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SettingTile(
            title: loc.themeAppColor,
            enabled: !useDeviceColor,
            newLineAction: ColorPickerAction(
              color: color,
              onChanged: (value) {
                ref
                    .read(themeColorValueProvider.notifier)
                    .set(value.toARGB32());
              },
            ),
          ),
          SettingTile(
            title: loc.themeSchemeVariant,
            enabled: !useDeviceColor,
            newLineAction: const SchemeVariantPickerAction(),
          ),
        ],
      ),
    );
  }
}
