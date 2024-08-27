import 'package:flutter/material.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          const SettingTile(),
          Slider.adaptive(value: 0.1, onChanged: (value) {}),
        ],
      ),
    );
  }
}
