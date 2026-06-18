import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/raw_button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';

class ButtonM3E extends StatelessWidget {
  const ButtonM3E.elevated({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = .small,
    this.shape = .round,
    this.icon,
  }) : _colorStyle = .elevated,
       error = false;

  const ButtonM3E.filled({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = .small,
    this.shape = .round,
    this.icon,
    this.error = false,
  }) : _colorStyle = .filled;

  const ButtonM3E.tonal({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = .small,
    this.shape = .round,
    this.icon,
    this.error = false,
  }) : _colorStyle = .tonal;

  const ButtonM3E.outlined({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = .small,
    this.shape = .round,
    this.icon,
    this.error = false,
  }) : _colorStyle = .outlined;

  const ButtonM3E.text({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = .small,
    this.shape = .round,
    this.icon,
    this.error = false,
  }) : _colorStyle = .text;

  final Widget child;
  final void Function()? onPressed;
  final ButtonSize size;
  final ButtonShape shape;
  final Widget? icon;
  final ButtonColorStyle _colorStyle;

  final bool error;

  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;
    final isRound = shape == .round;

    switch (_colorStyle) {
      case .elevated:
        return RawButtonM3E(
          onPressed: onPressed,
          backgroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(26),
              WidgetState.any: col.surfaceContainerLow,
            },
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.any: col.primary,
            },
          ),
          elevation: const WidgetStateProperty.fromMap({
            WidgetState.hovered: 1,
            WidgetState.disabled: 0,
            WidgetState.any: 1,
          }),
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: size.iconSpacing,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.any: isRound ? size.shape : size.squareShape,
          }),
          padding: size.padding,
          fontSize: size.fontSize,
          icon: icon,
          child: child,
        );
      case .filled:
        return RawButtonM3E(
          onPressed: onPressed,
          backgroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(26),
              WidgetState.any: error ? col.errorContainer : col.primary,
            },
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.any: error ? col.onErrorContainer : col.onPrimary,
            },
          ),
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: size.iconSpacing,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.any: isRound ? size.shape : size.squareShape,
          }),
          padding: size.padding,
          fontSize: size.fontSize,
          icon: icon,
          child: child,
        );
      case .tonal:
        return RawButtonM3E(
          onPressed: onPressed,
          backgroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(26),
              WidgetState.any: error ? col.error : col.secondaryContainer,
            },
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.any: error ? col.onError : col.onSecondaryContainer,
            },
          ),
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: size.iconSpacing,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.any: isRound ? size.shape : size.squareShape,
          }),
          padding: size.padding,
          fontSize: size.fontSize,
          icon: icon,
          child: child,
        );
      case .outlined:
        return RawButtonM3E(
          onPressed: onPressed,
          backgroundColor: const WidgetStateColor.fromMap(
            {WidgetState.any: Colors.transparent},
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.any: error ? col.error : col.onSurfaceVariant,
            },
          ),
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: size.iconSpacing,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.any: isRound ? size.shape : size.squareShape,
          }),
          padding: size.padding,
          fontSize: size.fontSize,
          outlineWidth: const WidgetStateProperty.fromMap({WidgetState.any: 1}),
          outlineColor: WidgetStateColor.fromMap(
            {WidgetState.any: error ? col.errorContainer : col.outlineVariant},
          ),
          icon: icon,
          child: child,
        );
      case .text:
        return RawButtonM3E(
          onPressed: onPressed,
          backgroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(26),
              WidgetState.any: Colors.transparent,
            },
          ),
          foregroundColor: WidgetStateColor.fromMap(
            {
              WidgetState.disabled: col.onSurface.withAlpha(97),
              WidgetState.any: error ? col.error : col.primary,
            },
          ),
          height: size.height,
          iconSize: size.iconSize,
          iconSpacing: size.iconSpacing,
          radius: WidgetStateProperty.fromMap({
            WidgetState.pressed: size.pressedShape,
            WidgetState.any: isRound ? size.shape : size.squareShape,
          }),
          padding: size.padding,
          fontSize: size.fontSize,
          icon: icon,
          child: child,
        );
    }
  }
}
