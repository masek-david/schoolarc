import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/textstyle_extension.dart';

class SettingTile extends StatelessWidget {
  const SettingTile(
      {super.key,
      required this.title,
      this.subtitle,
      this.leading,
      this.trailing,
      this.newLineAction,
      this.onTap,
      this.highlighted = false,
      this.enabled = true,
      this.contentPadding,
      this.isLast = false,
      this.isFirst = false,
      this.heroTag,
      this.titleColor});

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? newLineAction;
  final Function(BuildContext context)? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final bool highlighted;
  final bool enabled;
  final bool isLast;
  final bool isFirst;
  final String? heroTag;
  final Color? titleColor;

  static SettingTile withSwitch({
    required String title,
    required bool value,
    required void Function(bool value) onChanged,
    String? subtitle,
    bool enabled = true,
    bool highlighted = false,
    Widget? leading,
    Color? iconColor,
    EdgeInsetsGeometry? contentPadding,
    bool isFirst = false,
    bool isLast = false,
    Key? key,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      highlighted: highlighted,
      contentPadding: contentPadding,
      leading: leading,
      onTap: (context) => onChanged(!value),
      trailing:
          Switch(value: value, onChanged: enabled == false ? null : onChanged),
      isFirst: isFirst,
      isLast: isLast,
      key: key,
    );
  }

  static SettingTile withCheckbox({
    required String title,
    required bool value,
    required void Function(bool value) onChanged,
    String? subtitle,
    bool enabled = true,
    bool highlighted = false,
    Widget? leading,
    Color? iconColor,
    EdgeInsetsGeometry? contentPadding,
    bool isFirst = false,
    bool isLast = false,
    Key? key,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      highlighted: highlighted,
      contentPadding: contentPadding,
      leading: leading,
      onTap: (context) => onChanged(!value),
      trailing: Checkbox(
          value: value,
          tristate: false,
          onChanged:
              enabled == false ? null : (value) => onChanged(value as bool)),
      isFirst: isFirst,
      isLast: isLast,
      key: key,
    );
  }

  static SettingTile withTimePicker({
    required String title,
    required TimeOfDay time,
    required void Function(TimeOfDay value) onChanged,
    String? subtitle,
    bool? enabled,
    bool? highlighted,
    Widget? leading,
    Color? iconColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      enabled: enabled ?? true,
      highlighted: highlighted ?? false,
      leading: leading,
      onTap: (context) async {
        final value = await showTimePicker(
          context: context,
          initialTime: time,
        );

        if (value != null) {
          onChanged(value);
        }
      },
      trailing: Builder(builder: (context) {
        return Text(
          time.format(context),
          style: const TextStyle(fontSize: 16),
        );
      }),
      isFirst: isFirst,
      isLast: isLast,
    );
  }

  Text buildText(BuildContext context) {
    final color = titleColor ?? context.col.onSurface;

    return Text(
      title,
      style: context.txt.bodyMedium!.copyWithNunito(
          weight: enabled ? 700 : 400,
          color: color.withAlpha(enabled ? 255 : 80)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst || highlighted ? 8 : 1,
        bottom: isLast || highlighted ? 8 : 1,
      ),
      child: ClipRRect(
        borderRadius: highlighted
            ? BorderRadiusGeometry.circular(1000)
            : BorderRadius.vertical(
                top: isFirst
                    ? const Radius.circular(20)
                    : const Radius.circular(4),
                bottom: isLast
                    ? const Radius.circular(20)
                    : const Radius.circular(4),
              ),
        child: Material(
          color: highlighted
              ? context.col.primaryContainer
              : context.col.surfaceContainerLowest,
          child: InkWell(
            splashFactory: InkSparkle.splashFactory,
            onTap: enabled && onTap != null ? () => onTap!(context) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Row(
                    spacing: 16,
                    children: [
                      if (leading != null)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: leading!,
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            heroTag != null
                                ? Hero(
                                    tag: heroTag!,
                                    child: buildText(context),
                                  )
                                : buildText(context),
                            if (subtitle != null) Text(subtitle!),
                          ],
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                  if (newLineAction != null) ...[
                    const SizedBox(height: 12),
                    AbsorbPointer(
                      absorbing: enabled == false,
                      child: Opacity(
                        opacity: enabled ? 1 : 0.3,
                        child: newLineAction!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
