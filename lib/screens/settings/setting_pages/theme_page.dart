import 'package:flutter/material.dart';
import 'package:school_manager/screens/settings/widgets/color_picker_action.dart';
import 'package:school_manager/screens/settings/widgets/drop_down_action.dart';
import 'package:school_manager/screens/settings/widgets/scheme_variant_picker_action.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/theme_colors_showcase.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

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
  bool? themeMode = settings.get(Setting.themeMode);

  @override
  Widget build(BuildContext context) {
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
                settings.save(Setting.themeMode, value as bool?);
                setState(() {
                  themeMode = value;
                });
                widget.refreshTheme();
              },
              items: [
                DropdownMenuItem(
                    value: null, child: Text(loc.themeFollowSystem)),
                DropdownMenuItem(value: false, child: Text(loc.themeLight)),
                DropdownMenuItem(value: true, child: Text(loc.themeDark)),
              ],
            ),
          ),
          SettingTile.withSwitch(
            title: loc.themeOLEDTitle,
            subtitle: loc.themeOLEDSubtitle,
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
            title: loc.themeUseDeviceColors,
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
                loc.themeSystemColorWarning,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SettingTile(
            title: loc.themeAppColor,
            enabled: !useDeviceColor,
            newLineAction: ColorPickerAction(
              initialColor: Color(settings.get(Setting.themeColorValue)),
              onChanged: (color) {
                settings.save(Setting.themeColorValue, color.toARGB32());
                widget.refreshTheme();
              },
            ),
          ),
          SettingTile(
            title: loc.themeSchemeVariant,
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
