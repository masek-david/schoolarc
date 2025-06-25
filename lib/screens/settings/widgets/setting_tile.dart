import 'package:flutter/material.dart';
import 'package:school_manager/utils/extensions/timeofday_extension.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.newLineAction,
    this.onTap,
    this.highlighted = false,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Widget? newLineAction;
  final Function(BuildContext context)? onTap;
  final bool highlighted;
  final bool enabled;

  static SettingTile withSwitch({
    required String title,
    required bool value,
    required void Function(bool value) onChanged,
    String? subtitle,
    bool? enabled,
    bool? highlighted,
    IconData? icon,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      enabled: enabled ?? true,
      highlighted: highlighted ?? false,
      icon: icon,
      onTap: (context) => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  static SettingTile withTimePicker({
    required String title,
    required TimeOfDay time,
    required void Function(TimeOfDay value) onChanged,
    String? subtitle,
    bool? enabled,
    bool? highlighted,
    IconData? icon,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      enabled: enabled ?? true,
      highlighted: highlighted ?? false,
      icon: icon,
      onTap: (context) async {
        final value = await showTimePicker(context: context, initialTime: time);

        if (value != null) {
          onChanged(value);
        }
      },
      trailing: Text(
        '${time.hour}:${time.minuteStartingWithZero()}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !enabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: highlighted ? const EdgeInsets.all(16) : EdgeInsets.all(0),
            child: ListTile(
              enabled: enabled,
              onTap: onTap == null ? null : () => onTap!(context),
              tileColor: highlighted
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              shape: highlighted
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32))
                  : null,
              contentPadding: highlighted ? EdgeInsets.all(12) : null,
              leading: icon != null ? Icon(icon) : null,
              title: Text(
                title,
                style: TextStyle(
                  fontSize: highlighted ? 19 : null,
                ),
              ),
              subtitle: subtitle == null ? null : Text(subtitle!),
              trailing: trailing,
            ),
          ),
          if (newLineAction != null)
            Opacity(
              opacity: enabled ? 1 : 0.3,
              child: newLineAction!,
            ),
        ],
      ),
    );
  }
}
