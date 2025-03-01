import 'package:flutter/material.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/slider_action.dart';
import 'package:school_manager/screens/settings/widgets/switch_action.dart';

class TimetableSettings extends StatefulWidget {
  const TimetableSettings({
    super.key,
    required this.showWholeWeek,
    required this.tileWidth,
    required this.changeTileWidth,
    required this.changeShowWholeWeek,
  });

  final bool showWholeWeek;
  final double tileWidth;
  final void Function(double width) changeTileWidth;
  final void Function(bool value) changeShowWholeWeek;

  @override
  State<TimetableSettings> createState() => _TimetableSettingsState();
}

class _TimetableSettingsState extends State<TimetableSettings> {
  late bool showWholeWeek = widget.showWholeWeek;
  late double tileWidth = widget.tileWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingTile(
            label: 'Show 7 day week',
            trailing: SwitchAction(
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
            label: 'Tile width',
            newLineAction: SliderAction(
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
          ),
        ],
      ),
    );
  }
}
