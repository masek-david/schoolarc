import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/raw_button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class IconButtonM3E extends StatelessWidget {
  const IconButtonM3E.filled({
    super.key,
    required this.onPressed,
    this.size = .small,
    this.width = .defaultWidth,
    this.shape = .round,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.hoverElevation,
  }) : colorStyle = .filled;

  const IconButtonM3E.outlined({
    super.key,
    required this.onPressed,
    this.size = .small,
    this.width = .defaultWidth,
    this.shape = .round,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.hoverElevation,
  }) : colorStyle = .outlined;

  const IconButtonM3E.tonal({
    super.key,
    required this.onPressed,
    this.size = .small,
    this.width = .defaultWidth,
    this.shape = .round,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.hoverElevation,
  }) : colorStyle = .tonal;

  const IconButtonM3E({
    super.key,
    required this.onPressed,
    this.size = .small,
    this.width = .defaultWidth,
    this.shape = .round,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.hoverElevation,
  }) : colorStyle = .standard;

  final void Function()? onPressed;
  final Widget? icon;
  final IconButtonSize size;
  final IconButtonWidth width;
  final IconButtonColorStyle colorStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;
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

    double widthNumber;

    switch (width) {
      case .defaultWidth:
        widthNumber = size.defaultWidth;
      case .narrow:
        widthNumber = size.narrowWidth;
      case .wide:
        widthNumber = size.wideWidth;
    }

    if (onPressed == null) {
      bgCol ??= col.onSurface.withAlpha(25);
      fgCol ??= col.onSurface.withAlpha(97);

      if (colorStyle == .outlined) {
        outlineWidth = 1;
        outlineColor = col.outlineVariant;
      }
    } else {
      switch (colorStyle) {
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
        case .standard:
          bgCol ??= Colors.transparent;
          fgCol ??= col.onSurfaceVariant;
          hoverElev = 0;
      }
    }

    return RawButtonM3E(
      onPressed: onPressed,
      foregroundColor: fgCol,
      backgroundColor: bgCol,
      width: widthNumber,
      radius: shape == .square ? size.radius : size.height / 2,
      pressedRadius: size.pressedRadius,
      padding: 0,
      iconSize: size.iconSize,
      iconPadding: 0,
      height: size.height,
      fontSize: 0,
      elevation: elev,
      hoverElevation: hoverElev,
      shrinkAnimation: false,
      outlineColor: outlineColor,
      outlineWidth: outlineWidth,
      icon: icon,
    );
  }
}
