import 'package:flutter/material.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/settings/widgets/slider_action.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

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
    final loc = context.loc;

    return SizedBox(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingTile.withSwitch(
            title: loc.show7DayWeek,
            value: showWholeWeek,
            onChanged: (value) {
              setState(() {
                widget.changeShowWholeWeek(value);
                showWholeWeek = value;
              });
            },
          ),
          SettingTile(
            title: loc.timetableTileWidth,
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
