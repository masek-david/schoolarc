import 'package:flutter/material.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/setting_text_divider.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class ShortcutsPage extends StatelessWidget {
  const ShortcutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      heroTag: 'shortcuts',
      title: context.loc.shortcuts,
      children: [
        SettingTile(
          isFirst: true,
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
          isLast: true,
          title: context.loc.createExam,
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.keyboard_control_key),
              _KeyboardIcon('E'),
            ],
          ),
        ),
        SettingTextDivider(text: context.loc.shortcutWhenCreating),
        SettingTile(
          isFirst: true,
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
          isLast: true,
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
      width: 20,
      height: 20,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      child: Text(
        keyboardKey!,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
