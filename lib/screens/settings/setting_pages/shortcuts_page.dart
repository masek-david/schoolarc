import 'package:flutter/material.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';

class ShortcutsPage extends StatelessWidget {
  const ShortcutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shortcuts'),
      ),
      body: ListView(
        children: [
          SettingTile(
            title: 'Create homework',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_control_key),
                _KeyboardIcon('H'),
              ],
            ),
          ),
          SettingTile(
            title: 'Create an exam',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_control_key),
                _KeyboardIcon('E'),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'When creating: ',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          SettingTile(
            title: 'Search for a subject',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_control_key),
                _KeyboardIcon('F'),
              ],
            ),
          ),
          SettingTile(
            title: 'Choose a priority',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_control_key),
                _KeyboardIcon('1'),
                Text(' - '),
                _KeyboardIcon('4'),
              ],
            ),
          ),
          SettingTile(
            title: 'Pick a date',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_control_key),
                _KeyboardIcon('D'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyboardIcon extends StatelessWidget {
  const _KeyboardIcon(
    this.keyboardKey, {
    // ignore: unused_element_parameter
    super.key,
  });

  final String? keyboardKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 17,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      child: Text(
        keyboardKey!,
        style: TextStyle(
          height: 1,
          fontSize: 12,
        ),
      ),
    );
  }
}
