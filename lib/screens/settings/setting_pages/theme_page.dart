import 'package:flutter/material.dart';
import 'package:school_manager/screens/settings/widgets/color_picker_action.dart';
import 'package:school_manager/screens/settings/widgets/drop_down_action.dart';
import 'package:school_manager/screens/settings/widgets/scheme_variant_picker_action.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/switch_action.dart';
import 'package:school_manager/screens/settings/widgets/theme_colors_showcase.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({
    super.key,
    required this.refreshTheme,
  });

  final void Function() refreshTheme;

  @override
  Widget build(BuildContext context) {
    bool customColorEnabled = settings.get(Setting.themeUseMaterial) == false;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          const ThemeColorsShowcase(),
          SettingTile(
            label: 'Brightness',
            action: DropDownAction(
              initialValue: settings.get(Setting.themeMode),
              onChanged: (value) {
                bool? valueToBool = (value is bool) ? value : null;

                settings.save(Setting.themeMode, valueToBool);
                refreshTheme();
              },
              items: const [
                DropdownMenuItem(value: null, child: Text('Follow system')),
                DropdownMenuItem(value: false, child: Text('Light')),
                DropdownMenuItem(value: true, child: Text('Dark')),
              ],
            ),
          ),
          SettingTile(
            label: 'Use device colors',
            action: SwitchAction(
              initialValue: settings.get(Setting.themeUseMaterial),
              onChanged: (value) {
                settings.save(Setting.themeUseMaterial, value);
                refreshTheme();
              },
            ),
          ),
          if (!customColorEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Currently using system color. If you want to use custom color, turn off Use device colors.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SettingTile(
            label: 'App color',
            enabled: customColorEnabled,
            action: ColorPickerAction(
              initialColor: Color(settings.get(Setting.themeColorValue)),
              onChanged: (color) {
                settings.save(Setting.themeColorValue, color.value);
                refreshTheme();
              },
            ),
          ),
          SettingTile(
            label: '',
            enabled: customColorEnabled,
            action: SchemeVariantPickerAction(
              initialScheme: settings.get(Setting.themeDynamicSchemeVariantInt),
              onChanged: (value) {
                settings.save(Setting.themeDynamicSchemeVariantInt, value);
                refreshTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
