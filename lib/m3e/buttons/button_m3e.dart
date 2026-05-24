import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/raw_button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class ButtonM3E extends StatelessWidget {
  const ButtonM3E.elevated({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = .small,
    this.shape = .round,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.outlineColor,
    this.elevation,
    this.hoverElevation,
  }) : colorStyle = .elevated;

  const ButtonM3E.filled({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = .small,
    this.shape = .round,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.outlineColor,
    this.elevation,
    this.hoverElevation,
  }) : colorStyle = .filled;

  const ButtonM3E.tonal({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = .small,
    this.shape = .round,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.outlineColor,
    this.elevation,
    this.hoverElevation,
  }) : colorStyle = .tonal;

  const ButtonM3E.outlined({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = .small,
    this.shape = .round,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.outlineColor,
    this.elevation,
    this.hoverElevation,
  }) : colorStyle = .outlined;

  const ButtonM3E.text({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = .small,
    this.shape = .round,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.outlineColor,
    this.elevation,
    this.hoverElevation,
  }) : colorStyle = .text;

  final void Function()? onPressed;
  final Widget? child;
  final Widget? icon;
  final ButtonSize size;
  final ButtonColorStyle colorStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? outlineColor;
  final ButtonShape shape;
  final double? elevation;
  final double? hoverElevation;

  @override
  Widget build(BuildContext context) {
    final col = context.col;
    Color? bgCol = backgroundColor;
    Color? fgCol = foregroundColor;
    double elev = elevation ?? 0;
    double hoverElev = hoverElevation ?? 1;
    double? outlineWidth;
    Color? outlineColor;

    if (onPressed == null) {
      bgCol ??= col.onSurface.withAlpha(25);
      fgCol ??= col.onSurface.withAlpha(97);

      if (colorStyle == .outlined) {
        outlineWidth = 1;
        outlineColor = col.outlineVariant;
      }
    } else {
      switch (colorStyle) {
        case .elevated:
          bgCol ??= col.surfaceContainerLow;
          fgCol ??= col.primary;
          elev = 1;
          hoverElev = 3;
        case .filled:
          bgCol ??= col.primary;
          fgCol ??= col.onPrimary;
        case .tonal:
          bgCol ??= col.secondaryContainer;
          fgCol ??= col.onSecondaryContainer;
        case .outlined:
          bgCol ??= Colors.transparent;
          fgCol ??= col.onSurfaceVariant;
          outlineWidth = 1;
          outlineColor = col.outlineVariant;
          hoverElev = 0;
        case .text:
          bgCol ??= Colors.transparent;
          fgCol ??= col.primary;
          hoverElev = 0;
      }
    }

    return RawButtonM3E(
      onPressed: onPressed,
      foregroundColor: fgCol,
      backgroundColor: bgCol,
      width: null,
      radius: shape == .square ? size.radius : size.height / 2,
      pressedRadius: size.pressedRadius,
      padding: size.padding,
      iconSize: size.iconSize,
      iconPadding: size.iconPadding,
      height: size.height,
      fontSize: size.fontSize,
      icon: icon,
      elevation: elev,
      hoverElevation: hoverElev,
      shrinkAnimation: true,
      outlineColor: outlineColor,
      outlineWidth: outlineWidth,
      child: child,
    );
  }
}
