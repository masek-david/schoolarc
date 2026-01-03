import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
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
    this.titleColor,
    this.hapticFeedback = true,
  });

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
  final bool hapticFeedback;

  final animationDuration = const Duration(milliseconds: 200);
  final animationCurve = Curves.decelerate;

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
    Widget? newLineAction,
    Key? key,
  }) {
    void change(bool newValue) {
      onChanged(newValue);
      vibrate.switchUI(newValue);
    }

    return SettingTile(
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      highlighted: highlighted,
      contentPadding: contentPadding,
      leading: leading,
      onTap: (context) => change(!value),
      trailing: Switch(
        value: value,
        onChanged: enabled == false ? null : change,
      ),
      newLineAction: newLineAction,
      isFirst: isFirst,
      isLast: isLast,
      key: key,
      hapticFeedback: false,
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
        onChanged: enabled == false
            ? null
            : (value) => onChanged(value as bool),
      ),
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
      trailing: Builder(
        builder: (context) {
          return Text(
            time.format(context),
            style: const TextStyle(fontSize: 16),
          );
        },
      ),
      isFirst: isFirst,
      isLast: isLast,
    );
  }

  Widget buildText(BuildContext context) {
    final color =
        titleColor ??
        (highlighted ? context.col.onPrimaryContainer : context.col.onSurface);

    return SizedBox(
      width: double.infinity,
      child: Text(
        title,
        style: googleSansFlex(
          size: 14,
          weight: enabled ? 700 : 400,
          color: color.withAlpha(enabled ? 255 : 80),
          roundness: 100,
        ),
      ),
    );
  }

  BorderRadiusGeometry getBorder() {
    return highlighted
        ? BorderRadiusGeometry.circular(1000)
        : BorderRadius.vertical(
            top: isFirst ? const Radius.circular(20) : const Radius.circular(4),
            bottom: isLast
                ? const Radius.circular(20)
                : const Radius.circular(4),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst || highlighted ? 8 : 1,
        bottom: isLast || highlighted ? 8 : 1,
      ),
      child: Material(
        borderRadius: getBorder(),
        clipBehavior: Clip.antiAlias,
        color: highlighted
            ? context.col.primaryContainer
            : context.col.surfaceContainerLowest,
        child: InkWell(
          splashFactory: InkSparkle.splashFactory,
          onTap: enabled && onTap != null
              ? () {
                  if (hapticFeedback) {
                    vibrate.light();
                  }
                  onTap!(context);
                }
              : null,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  AnimatedSize(
                    curve: animationCurve,
                    duration: animationDuration,
                    child: SizedBox(
                      width: leading == null ? 16 : 56,
                      child: leading,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        heroTag != null
                            ? Hero(
                                tag: heroTag!,
                                flightShuttleBuilder:
                                    (
                                      flightContext,
                                      animation,
                                      flightDirection,
                                      fromHeroContext,
                                      toHeroContext,
                                    ) {
                                      return AnimatedBuilder(
                                        animation: animation,
                                        builder: (context, _) {
                                          return Material(
                                            color: Colors.transparent,
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: Text(
                                                title,
                                                style: googleSansFlex(
                                                  size:
                                                      14 + animation.value * 30,
                                                  weight: enabled ? 700 : 400,
                                                  roundness: 100,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                child: buildText(context),
                              )
                            : buildText(context),
                        if (subtitle != null) Text(subtitle!),
                      ],
                    ),
                  ),
                  if (trailing != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: trailing!,
                    ),
                  const SizedBox(width: 16),
                ],
              ),
              AnimatedSize(
                duration: animationDuration,
                curve: animationCurve,
                child: SizedBox(
                  height: newLineAction == null ? 16 : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AbsorbPointer(
                      absorbing: enabled == false,
                      child: Opacity(
                        opacity: enabled ? 1 : 0.3,
                        child: newLineAction,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
