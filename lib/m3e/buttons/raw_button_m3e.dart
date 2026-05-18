import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart' show vibrate;

class RawButtonM3E extends StatefulWidget {
  const RawButtonM3E({
    super.key,
    required this.onPressed,
    this.child,
    this.icon,
    this.shrinkAnimation = true,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.elevation,
    required this.hoverElevation,
    required this.width,
    required this.height,
    required this.iconSize,
    required this.iconPadding,
    required this.radius,
    required this.pressedRadius,
    required this.padding,
    required this.fontSize,
    this.outlineColor,
    this.outlineWidth,
    this.alignment = .center,
  });

  final void Function()? onPressed;
  final Widget? child;
  final Widget? icon;
  final double? width;
  final double height;
  final double iconSize;
  final double iconPadding;
  final double radius;
  final double pressedRadius;
  final double padding;
  final double fontSize;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;
  final double hoverElevation;
  final double? outlineWidth;
  final Color? outlineColor;
  final MainAxisAlignment alignment;

  /// if true, the button will "spring" to become smaller if the animation
  /// overshoots maximum border radius (happens only for fullyRounded button)
  final bool shrinkAnimation;

  @override
  State<RawButtonM3E> createState() => _RawButtonM3EState();
}

class _RawButtonM3EState extends State<RawButtonM3E>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: durationFastSpatial,
  );
  late Animation _animation = getAnimation();
  bool hovered = false;
  bool focused = false;

  Animation getAnimation() {
    return Tween<double>(
      begin: widget.radius,
      end: widget.pressedRadius,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: curveFastSpatial,
        reverseCurve: curveFastSpatial.flipped,
      ),
    );
  }

  Future<void> animateTapUp() async {
    if (_controller.value < 0.3) {
      await Future.delayed(
        durationFastSpatial * (0.3 - _controller.value),
      );
      if (!mounted) return;
    }
    _controller.animateBack(0);
  }

  void animateTapDown() {
    _controller.value = 0;
    _controller.animateTo(1).then((value) => vibrate.medium());
  }

  void animateTapCancel() {
    _controller.animateBack(0);
  }

  @override
  void didUpdateWidget(covariant RawButtonM3E oldWidget) {
    if (oldWidget.pressedRadius != widget.pressedRadius ||
        oldWidget.radius != widget.radius) {
      _animation = getAnimation();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgCol = widget.backgroundColor;
    final fgCol = widget.foregroundColor;
    final enabled = widget.onPressed != null;

    // Semantics fixed the input padding - if it wasnt here, taping the buttons before would trigger this one
    return Semantics(
      child: _InputPadding(
        minSize: const Size(48, 48),
        child: AnimatedBuilder(
          animation: _animation,
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
                SizedBox(width: widget.iconPadding),
              if (widget.child != null) Flexible(child: widget.child!),
            ],
          ),
          builder: (context, child) {
            double addOffset = 0;
            if (widget.shrinkAnimation &&
                _animation.value > widget.height / 2) {
              addOffset = _animation.value - widget.height / 2;
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: addOffset),

              child: Stack(
                fit: .passthrough,
                clipBehavior: .none,
                children: [
                  if (focused)
                    Positioned.fill(
                      top: -5,
                      bottom: -5,
                      left: -5,
                      right: -5,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              _animation.value + 6,
                            ),
                            border: Border.all(
                              color: context.col.secondary,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Material(
                    elevation: enabled && hovered
                        ? widget.hoverElevation
                        : widget.elevation,
                    animationDuration: Duration.zero,
                    color: bgCol,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(
                        _animation.value,
                      ),
                      side:
                          widget.outlineColor != null &&
                              widget.outlineWidth != null
                          ? BorderSide(
                              color: widget.outlineColor!,
                              width: widget.outlineWidth!,
                            )
                          : .none,
                    ),
                    clipBehavior: .antiAlias,
                    textStyle: context.txt.labelLarge!.copyWith(
                      color: fgCol,
                      fontSize: widget.fontSize,
                    ),
                    child: InkWell(
                      onFocusChange: (value) {
                        setState(() {
                          focused = value;
                        });
                      },
                      onHover: (value) {
                        setState(() {
                          hovered = value;
                        });
                      },
                      focusColor: fgCol.withAlpha(26),
                      hoverColor: fgCol.withAlpha(20),
                      highlightColor: fgCol.withAlpha(20),
                      splashColor: fgCol.withAlpha(26),
                      onTapDown: enabled ? (details) => animateTapDown() : null,
                      onTapUp: enabled ? (details) => animateTapUp() : null,
                      onTapCancel: enabled ? () => animateTapCancel() : null,
                      onTap: widget.onPressed,
                      child: SizedBox(
                        height: widget.height,
                        width: widget.width,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: (widget.padding - addOffset).clamp(
                              0,
                              double.infinity,
                            ),
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
