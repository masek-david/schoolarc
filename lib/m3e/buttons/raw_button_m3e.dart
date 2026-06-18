import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:schoolarc/m3e/instant_ink_well.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class RawButtonM3E extends StatefulWidget {
  const RawButtonM3E({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.width,
    this.height = 40,
    this.iconSize = 20,
    this.iconSpacing = 8,
    this.radius,
    this.padding = 16,
    this.fontSize = 14,
    this.alignment = .center,
    this.outlineWidth,
    this.outlineColor,
    this.selected = false,
  });

  final void Function()? onPressed;
  final Widget? child;
  final Widget? icon;
  final double? width;
  final double height;
  final double iconSize;
  final double iconSpacing;
  final double padding;
  final double fontSize;
  final bool selected;
  final MainAxisAlignment alignment;
  final WidgetStateProperty<Color>? backgroundColor;
  final WidgetStateProperty<Color>? foregroundColor;
  final WidgetStateProperty<BorderRadiusGeometry>? radius;
  final WidgetStateProperty<double>? elevation;
  final WidgetStateProperty<double>? outlineWidth;
  final WidgetStateProperty<Color>? outlineColor;

  @override
  State<RawButtonM3E> createState() => _RawButtonM3EState();
}

class _RawButtonM3EState extends State<RawButtonM3E>
    with SingleTickerProviderStateMixin {
  final _stateController = WidgetStatesController();

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    _stateController.addListener(_updateState);

    _stateController.update(.disabled, widget.onPressed == null);
    _stateController.update(.selected, widget.selected);

    super.initState();
  }

  @override
  void didUpdateWidget(RawButtonM3E oldWidget) {
    _stateController.update(.disabled, widget.onPressed == null);
    _stateController.update(.selected, widget.selected);

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _stateController.removeListener(_updateState);
    _stateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgCol = widget.backgroundColor?.resolve(_stateController.value);
    final fgCol = widget.foregroundColor?.resolve(_stateController.value);

    // Semantics fixed the input padding - if it wasnt here, taping the buttons before would trigger this one
    return Semantics(
      focused: _stateController.value.contains(WidgetState.focused),
      focusable: true,
      enabled: widget.onPressed != null,
      checked: _stateController.value.contains(WidgetState.selected),
      button: true,
      child: _InputPadding(
        minSize: const Size(48, 48),
        child: TweenAnimationBuilder<BorderRadiusGeometry>(
          duration: EffectsMotion.defaultMotion.duration,
          curve: EffectsMotion.defaultMotion.curve,
          tween: Tween<BorderRadiusGeometry>(
            end:
                widget.radius?.resolve(_stateController.value) ??
                BorderRadius.circular(0),
          ),
          builder: (context, radius, child) {
            return Stack(
              fit: .passthrough,
              clipBehavior: .none,
              children: [
                if (_stateController.value.contains(WidgetState.focused))
                  Positioned.fill(
                    top: -5,
                    bottom: -5,
                    left: -5,
                    right: -5,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius.add(.circular(5)),
                          border: Border.all(
                            color: context.col.secondary,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                Material(
                  animationDuration: Duration.zero,
                  borderRadius: radius,
                  color: Colors.transparent,
                  elevation:
                      widget.elevation?.resolve(_stateController.value) ?? 0,
                  child: InstantInkWell(
                    stateLayerColor: fgCol,
                    borderRadius: radius,
                    statesController: _stateController,
                    onTap: widget.onPressed,
                    child: Material(
                      textStyle: context.txt.labelLarge!.copyWith(
                        color: fgCol,
                        fontSize: widget.fontSize,
                      ),
                      color: bgCol,
                      child: Container(
                        decoration:
                            widget.outlineColor != null &&
                                widget.outlineWidth != null
                            ? BoxDecoration(
                                borderRadius: radius,
                                border: Border.all(
                                  color: widget.outlineColor!.resolve(
                                    _stateController.value,
                                  ),
                                  width: widget.outlineWidth!.resolve(
                                    _stateController.value,
                                  ),
                                ),
                              )
                            : null,
                        height: widget.height,
                        width: widget.width,
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.padding,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          child: Row(
            mainAxisSize: .min,
            mainAxisAlignment: widget.alignment,
            children: [
              if (widget.icon != null)
                Theme(
                  data: Theme.of(context).copyWith(
                    iconTheme: IconThemeData(
                      color: fgCol,
                      size: widget.iconSize,
                    ),
                  ),
                  child: widget.icon!,
                ),
              if (widget.icon != null && widget.child != null)
                SizedBox(width: widget.iconSpacing),
              if (widget.child != null) Flexible(child: widget.child!),
            ],
          ),
        ),
      ),
    );
  }
}

/// COPIED from package:flutter/src/material/button_style_button.dart
///
/// A widget to pad the area around a [ButtonStyleButton]'s inner [Material].
///
/// Redirect taps that occur in the padded area around the child to the center
/// of the child. This increases the size of the button and the button's
/// "tap target", but not its material or its ink splashes.
class _InputPadding extends SingleChildRenderObjectWidget {
  const _InputPadding({super.child, required this.minSize});

  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderInputPadding(minSize);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderInputPadding renderObject,
  ) {
    renderObject.minSize = minSize;
  }
}

class _RenderInputPadding extends RenderShiftedBox {
  _RenderInputPadding(this._minSize, [RenderBox? child]) : super(child);

  Size get minSize => _minSize;
  Size _minSize;
  set minSize(Size value) {
    if (_minSize == value) {
      return;
    }
    _minSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicWidth(height), minSize.width);
    }
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicHeight(width), minSize.height);
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicWidth(height), minSize.width);
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicHeight(width), minSize.height);
    }
    return 0.0;
  }

  Size _computeSize({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
  }) {
    if (child != null) {
      final Size childSize = layoutChild(child!, constraints);
      final double width = math.max(childSize.width, minSize.width);
      final double height = math.max(childSize.height, minSize.height);
      return constraints.constrain(Size(width, height));
    }
    return Size.zero;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.dryLayoutChild,
    );
  }

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final RenderBox? child = this.child;
    if (child == null) {
      return null;
    }
    final double? result = child.getDryBaseline(constraints, baseline);
    if (result == null) {
      return null;
    }
    final Size childSize = child.getDryLayout(constraints);
    return result +
        Alignment.center
            .alongOffset(getDryLayout(constraints) - childSize as Offset)
            .dy;
  }

  @override
  void performLayout() {
    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );
    if (child != null) {
      final childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = Alignment.center.alongOffset(
        size - child!.size as Offset,
      );
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) {
      return true;
    }
    final Offset center = child!.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (BoxHitTestResult result, Offset position) {
        assert(position == center);
        return child!.hitTest(result, position: center);
      },
    );
  }
}
