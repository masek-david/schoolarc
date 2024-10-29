import 'package:flutter/material.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/slider_action.dart';
import 'package:school_manager/screens/settings/widgets/switch_action.dart';

class TimetableSettings extends StatefulWidget {
  const TimetableSettings({
    super.key,
    required this.showWholeWeek,
    required this.tileWidth,
    required this.showSubjectNames,
    required this.changeShowSubjectName,
    required this.changeTileWidth,
    required this.changeShowWholeWeek,
  });

  final bool showWholeWeek;
  final bool showSubjectNames;
  final double tileWidth;
  final void Function(bool value) changeShowSubjectName;
  final void Function(double width) changeTileWidth;
  final void Function(bool value) changeShowWholeWeek;

  @override
  State<TimetableSettings> createState() => _TimetableSettingsState();
}

class _TimetableSettingsState extends State<TimetableSettings> {
  late bool showWholeWeek = widget.showWholeWeek;
  late double tileWidth = widget.tileWidth;
  late bool showSubjectNames = widget.showSubjectNames;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingTile(
          label: 'Show 7 day week',
          action: SwitchAction(
            initialValue: showWholeWeek,
            onChanged: (value) {
              setState(() {
                widget.changeShowWholeWeek(value);
                showWholeWeek = value;
              });
            },
          ),
        ),
        SettingTile(
          label: 'Show names of subjects',
          action: SwitchAction(
            initialValue: showSubjectNames,
            onChanged: (value) {
              setState(() {
                widget.changeShowSubjectName(value);
                showSubjectNames = value;
              });
            },
          ),
        ),
        SettingTile(
          label: 'Tile width',
          action: SliderAction(
            inititalValue: tileWidth.toDouble(),
            min: 60,
            max: 160,
            divisions: 10,
            onChanged: (value) {
              setState(() {
                widget.changeTileWidth(value);
                tileWidth = value;
              });
            },
          ),
        )
      ],
    );
  }
}
