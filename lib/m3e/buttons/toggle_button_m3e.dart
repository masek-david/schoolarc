import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/raw_button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';

class ToggleIconButtonM3E extends StatelessWidget {
  const ToggleIconButtonM3E({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = .small,
    this.shape = .round,
    this.width = .defaultWidth,
    required this.selected,
  }) : _colorStyle = .standard;

  const ToggleIconButtonM3E.filled({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = .small,
    this.shape = .round,
    this.width = .defaultWidth,
    required this.selected,
  }) : _colorStyle = .filled;

  const ToggleIconButtonM3E.tonal({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = .small,
    this.shape = .round,
    this.width = .defaultWidth,
    required this.selected,
  }) : _colorStyle = .tonal;

  const ToggleIconButtonM3E.outlined({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = .small,
    this.shape = .round,
    this.width = .defaultWidth,
    required this.selected,
  }) : _colorStyle = .outlined;

  final void Function()? onPressed;
  final bool selected;
  final IconButtonSize size;
  final IconButtonWidth width;
  final ButtonShape shape;
  final Widget? icon;
  final IconButtonColorStyle _colorStyle;

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
          selected: selected,
          backgroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(26),
              WidgetState.selected: col.primary,
              WidgetState.any: col.surfaceContainer,
            },
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.selected: col.onPrimary,
              WidgetState.any: col.onSurfaceVariant,
            },
          ),
          width: widthComputed,
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: 0,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.selected: size.squareShape,
            WidgetState.any: isRound ? .circular(fullRadius) : size.squareShape,
          }),
          padding: 0,
          fontSize: 0,
          icon: icon,
          child: null,
        );
      case .tonal:
        return RawButtonM3E(
          onPressed: onPressed,
          selected: selected,
          backgroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(26),
              WidgetState.selected: col.secondary,
              WidgetState.any: col.secondaryContainer,
            },
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.selected: col.onSecondary,
              WidgetState.any: col.onSecondaryContainer,
            },
          ),
          width: widthComputed,
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: 0,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.selected: size.squareShape,
            WidgetState.any: isRound ? .circular(fullRadius) : size.squareShape,
          }),
          padding: 0,
          fontSize: 0,
          icon: icon,
          child: null,
        );
      case .outlined:
        return RawButtonM3E(
          onPressed: onPressed,
          selected: selected,
          backgroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.selected: col.inverseSurface,
              WidgetState.any: Colors.transparent,
            },
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.selected: col.onInverseSurface,
              WidgetState.any: col.onSurfaceVariant,
            },
          ),
          width: widthComputed,
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: 0,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.selected: size.squareShape,
            WidgetState.any: isRound ? .circular(fullRadius) : size.squareShape,
          }),
          padding: 0,
          fontSize: 0,
          outlineWidth: const WidgetStateProperty.fromMap({
            WidgetState.selected: 0,
            WidgetState.any: 1,
          }),
          outlineColor: WidgetStateColor.fromMap({
            WidgetState.selected: Colors.transparent,
            WidgetState.any: col.outlineVariant,
          }),
          icon: icon,
          child: null,
        );
      case .standard:
        return RawButtonM3E(
          onPressed: onPressed,
          selected: selected,
          backgroundColor: const WidgetStateColor.fromMap(
            {
              WidgetState.any: Colors.transparent,
            },
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.selected: col.primary,
              WidgetState.any: col.onSurfaceVariant,
            },
          ),
          width: widthComputed,
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: 0,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.selected: size.squareShape,
            WidgetState.any: isRound ? .circular(fullRadius) : size.squareShape,
          }),
          padding: 0,
          fontSize: 0,
          icon: icon,
          child: null,
        );
    }
  }
}
