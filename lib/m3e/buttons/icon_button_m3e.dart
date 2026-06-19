import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/raw_button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';

class IconButtonM3E extends StatelessWidget {
  const IconButtonM3E({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = .small,
    this.shape = .round,
    this.width = .defaultWidth,
    this.backgroundColor,
    this.foregroundColor,
  }) : _colorStyle = .standard;

  const IconButtonM3E.filled({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = .small,
    this.shape = .round,
    this.width = .defaultWidth,
    this.backgroundColor,
    this.foregroundColor,
  }) : _colorStyle = .filled;

  const IconButtonM3E.tonal({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = .small,
    this.shape = .round,
    this.width = .defaultWidth,
    this.backgroundColor,
    this.foregroundColor,
  }) : _colorStyle = .tonal;

  const IconButtonM3E.outlined({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = .small,
    this.shape = .round,
    this.width = .defaultWidth,
    this.backgroundColor,
    this.foregroundColor,
  }) : _colorStyle = .outlined;

  final void Function()? onPressed;
  final IconButtonSize size;
  final IconButtonWidth width;
  final ButtonShape shape;
  final Widget? icon;
  final IconButtonColorStyle _colorStyle;

  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;
    final isRound = shape == .round;

    final double widthComputed;

    switch (width) {
      case .defaultWidth:
        widthComputed = size.defaultWidth;
      case .narrow:
        widthComputed = size.narrowWidth;
      case .wide:
        widthComputed = size.wideWidth;
    }

    final fullRadius = min(widthComputed, size.height) / 2;

    switch (_colorStyle) {
      case .filled:
        return RawButtonM3E(
          onPressed: onPressed,
          backgroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(26),
              WidgetState.any: backgroundColor ?? col.primary,
            },
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.any: foregroundColor ?? col.onPrimary,
            },
          ),
          elevation: const WidgetStateProperty.fromMap({WidgetState.any: 0}),
          width: widthComputed,
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: 0,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.any: isRound ? .circular(fullRadius) : size.squareShape,
          }),
          padding: 0,
          fontSize: 0,
          outlineWidth: null,
          outlineColor: null,
          icon: icon,
          child: null,
        );

      case .tonal:
        return RawButtonM3E(
          onPressed: onPressed,
          backgroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(26),
              WidgetState.any: backgroundColor ?? col.secondaryContainer,
            },
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.any: foregroundColor ?? col.onSecondaryContainer,
            },
          ),
          elevation: const WidgetStateProperty.fromMap({WidgetState.any: 0}),
          width: widthComputed,
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: 0,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.any: isRound ? .circular(fullRadius) : size.squareShape,
          }),
          padding: 0,
          fontSize: 0,
          outlineWidth: null,
          outlineColor: null,
          icon: icon,
          child: null,
        );

      case .outlined:
        return RawButtonM3E(
          onPressed: onPressed,
          backgroundColor: const WidgetStateColor.fromMap(
            {
              WidgetState.any: Colors.transparent,
            },
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.any: foregroundColor ?? col.onSurfaceVariant,
            },
          ),
          elevation: const WidgetStateProperty.fromMap({WidgetState.any: 0}),
          width: widthComputed,
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: 0,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.any: isRound ? .circular(fullRadius) : size.squareShape,
          }),
          padding: 0,
          fontSize: 0,
          outlineWidth: const WidgetStateProperty.fromMap({
            WidgetState.any: 1,
          }),
          outlineColor: WidgetStateColor.fromMap({
            WidgetState.any: col.outlineVariant,
          }),
          icon: icon,
          child: null,
        );

      case .standard:
        return RawButtonM3E(
          onPressed: onPressed,
          backgroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.any: backgroundColor ?? Colors.transparent,
            },
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.any: foregroundColor ?? col.onSurfaceVariant,
            },
          ),
          elevation: const WidgetStateProperty.fromMap({
            WidgetState.any: 0,
          }),
          width: widthComputed,
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: 0,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.any: isRound ? .circular(fullRadius) : size.squareShape,
          }),
          padding: 0,
          fontSize: 0,
          outlineWidth: null,
          outlineColor: null,
          icon: icon,
          child: null,
        );
    }
  }
}
