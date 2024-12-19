import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.label,
    this.text,
    this.icon,
    this.trailing,
    this.newLineAction,
    this.onTap,
    this.highlighted = false,
    this.enabled = true,
  });

  final String label;
  final String? text;
  final IconData? icon;
  final Widget? trailing;
  final Widget? newLineAction;
  final Function()? onTap;
  final bool highlighted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !enabled,
      child: Column(
        children: [
          Padding(
            padding: highlighted ? const EdgeInsets.all(16) : EdgeInsets.all(0),
            child: ListTile(
              enabled: enabled,
              onTap: onTap,
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
                label,
                style: TextStyle(
                  fontSize: highlighted ? 19 : null,
                ),
              ),
              subtitle: text == null ? null : Text(text!),
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
