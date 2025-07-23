import 'package:flutter/material.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class ShortcutsPage extends StatelessWidget {
  const ShortcutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.shortcuts),
      ),
      body: ListView(
        children: [
          SettingTile(
            title: context.loc.createHomework,
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_control_key),
                _KeyboardIcon('H'),
              ],
            ),
          ),
          SettingTile(
            title: context.loc.createExam,
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_control_key),
                _KeyboardIcon('E'),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              context.loc.shortcutWhenCreating,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          SettingTile(
            title: context.loc.searchForSubject,
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_control_key),
                _KeyboardIcon('F'),
              ],
            ),
          ),
          SettingTile(
            title: context.loc.choosePriority,
            trailing: const Row(
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
            title: context.loc.pickDate,
            trailing: const Row(
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
        style: const TextStyle(
          height: 1,
          fontSize: 12,
        ),
      ),
    );
  }
}
