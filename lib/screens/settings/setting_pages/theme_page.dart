import 'package:flutter/material.dart';
import 'package:school_manager/screens/settings/widgets/color_picker_action.dart';
import 'package:school_manager/screens/settings/widgets/drop_down_action.dart';
import 'package:school_manager/screens/settings/widgets/scheme_variant_picker_action.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/theme_colors_showcase.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({
    super.key,
    required this.refreshTheme,
  });

  final void Function() refreshTheme;

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  bool themeUseOled = settings.get(Setting.themeUseOled);
  bool useDeviceColor = settings.get(Setting.themeUseDeviceColor);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          const ThemeColorsShowcase(),
          SettingTile(
            title: 'Brightness',
            trailing: DropDownAction(
              initialValue: settings.get(Setting.themeMode),
              onChanged: (value) {
                bool? valueToBool = (value is bool) ? value : null;

                settings.save(Setting.themeMode, valueToBool);
                widget.refreshTheme();
              },
              items: const [
                DropdownMenuItem(value: null, child: Text('Follow system')),
                DropdownMenuItem(value: false, child: Text('Light')),
                DropdownMenuItem(value: true, child: Text('Dark')),
              ],
            ),
          ),
          SettingTile.withSwitch(
            title: 'OLED black',
            subtitle: 'Works only in dark mode',
            value: themeUseOled,
            onChanged: (value) {
              settings.save(Setting.themeUseOled, !themeUseOled);
              setState(() {
                themeUseOled = !themeUseOled;
              });
              widget.refreshTheme();
            },
          ),
          SettingTile.withSwitch(
            title: 'Use device colors',
            value: useDeviceColor,
            onChanged: (value) {
              settings.save(Setting.themeUseDeviceColor, value);
              setState(() {
                useDeviceColor = value;
              });
              widget.refreshTheme();
            },
          ),
          if (useDeviceColor)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Currently using system color. If you want to use custom color, turn off Use device colors.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SettingTile(
            title: 'App color',
            enabled: !useDeviceColor,
            newLineAction: ColorPickerAction(
              initialColor: Color(settings.get(Setting.themeColorValue)),
              onChanged: (color) {
                // ignore: deprecated_member_use
                settings.save(Setting.themeColorValue, color.value);
                widget.refreshTheme();
              },
            ),
          ),
          SettingTile(
            title: '',
            enabled: !useDeviceColor,
            newLineAction: SchemeVariantPickerAction(
              initialScheme: settings.get(Setting.themeDynamicSchemeVariantInt),
              onChanged: (value) {
                settings.save(Setting.themeDynamicSchemeVariantInt, value);
                widget.refreshTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
