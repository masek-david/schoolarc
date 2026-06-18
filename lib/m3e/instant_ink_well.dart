import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Ripple {
  Ripple({
    required this.progressController,
    required this.opacityController,
    required this.center,
    required this.maxRadius,
  });

  /// The animation of the ink expanding
  final AnimationController progressController;

  /// The animation of the ink color
  final AnimationController opacityController;
  final Offset center;
  final double maxRadius;
  TickerFuture? _progressTicker;
  bool animatingUp = false;

  /// Called when [Ripple] is created, starts the progress and opacity animation
  void animateTapDown() {
    // this value is guessed, because the ink doesnt start from the begining, this moves it more to the middle
    _progressTicker = progressController.forward(from: 0.4);
    opacityController.forward();
  }

  /// Called when the finger is lifted - waits for progress animation to finish and
  /// then fades the ink away, disposing controllers in the end
  Future<void> animateTapUp({required void Function() onComplete}) async {
    animatingUp = true;
    await _progressTicker?.orCancel;
    await opacityController.reverse();

    onComplete();
    disposeControllers();
  }

  void disposeControllers() {
    progressController.dispose();
    opacityController.dispose();
  }
}

/// [WidgetState.Pressed] is set on the first frame of touch if the child isn't in a scrollable.
/// If it is inside a scrollable, to prevent a swipe being registered as a tap,
/// it waits before triggering
class InstantInkWell extends StatefulWidget {
  const InstantInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.stateLayerColor,
    this.borderRadius = BorderRadius.zero,
    this.progressDuration = const Duration(milliseconds: 250),
    this.opacityDuration = const Duration(milliseconds: 100),
    this.opacityReverseDuration = const Duration(milliseconds: 200),
    this.progressCurve = Curves.easeInOut,
    this.opacityCurve = Curves.linear,
    this.statesController,
  });

  final Widget child;
  final VoidCallback? onTap;
  final WidgetStatesController? statesController;
  final BorderRadiusGeometry borderRadius;
  final Color? stateLayerColor;
  final Duration progressDuration;
  final Duration opacityDuration;
  final Duration opacityReverseDuration;
  final Curve progressCurve;
  final Curve opacityCurve;

  @override
  State<InstantInkWell> createState() => _InstantInkWellState();
}

class _InstantInkWellState extends State<InstantInkWell>
    with TickerProviderStateMixin {
  late final TapGestureRecognizer _recognizer;
  bool hovered = false;
  bool focused = false;

  // TODO when you touch by a second finger while one is already holding, it shouldnt show

  /// Map of event.pointer of touch events and ripples
  final Map<int, Ripple> ripples = {};

  // TODO instant animation should work only in non scrollable layouts
  late final bool instantAnimation;

  @override
  void initState() {
    super.initState();

    // final scrollable = Scrollable.maybeOf(context);
    // instantAnimation = scrollable == null;
    instantAnimation = false;

    _recognizer = TapGestureRecognizer()
      ..onTap = () {
        widget.onTap?.call();
        if (!instantAnimation) {}
      };
  }

  @override
  void dispose() {
    _recognizer.dispose();
    for (var element in ripples.values) {
      element.disposeControllers();
    }
    super.dispose();
  }

  double _computeMaxRadius(Size size, Offset point) {
    return [
      (point - Offset.zero).distance,
      (point - Offset(size.width, 0)).distance,
      (point - Offset(0, size.height)).distance,
      (point - Offset(size.width, size.height)).distance,
    ].reduce(math.max);
  }

  void _createRipple({
    required int id,
    required Offset center,
    required double maxRadius,
  }) {
    final ripple = Ripple(
      progressController: AnimationController(
        vsync: this,
        duration: widget.progressDuration,
      ),
      opacityController: AnimationController(
        vsync: this,
        duration: widget.opacityDuration,
        reverseDuration: widget.opacityReverseDuration,
      ),
      center: center,
      maxRadius: maxRadius,
    )..animateTapDown();

    setState(() {
      ripples[id] = ripple;
    });
  }

  void _stopRipple(int id) {
    final ripple = ripples[id];
    if (ripple == null) return;
    if (!ripple.animatingUp) {
      ripple.animateTapUp(
        onComplete: () {
          ripples.remove(id);
        },
      );

      widget.statesController?.update(.pressed, false);
    }
  }

  // TODO test in a scrollable
  void _handlePointerMove(PointerMoveEvent event) {
    if (widget.onTap == null) return;

    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(event.position);

    if (!box.size.contains(localPosition)) {
      _stopRipple(event.pointer);
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.onTap == null) return;

    final box = context.findRenderObject() as RenderBox;
    final center = box.globalToLocal(event.position);

    _createRipple(
      id: event.pointer,
      center: center,
      maxRadius: _computeMaxRadius(box.size, center),
    );

    _recognizer.addPointer(event);

    widget.statesController?.update(.pressed, true);
  }

  void _handlePointerUpCancel(PointerEvent event) {
    if (widget.onTap == null) return;
    _stopRipple(event.pointer);
  }

  @override
  Widget build(BuildContext context) {
    final stateLayerColor =
        widget.stateLayerColor ?? Theme.of(context).colorScheme.onSurface;

    return Focus(
      onFocusChange: (value) {
        widget.statesController?.update(.focused, value);
        setState(() {
          focused = value;
        });
      },
      onKeyEvent: (node, event) {
        final isSpace = event.logicalKey == LogicalKeyboardKey.space;
        final isEnter =
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter;

        if (isSpace || isEnter) {
          final box = context.findRenderObject() as RenderBox;
          final center = box.size.center(Offset.zero);

          if (event is KeyDownEvent) {
            widget.statesController?.update(.pressed, true);
            // The id for all keyboard ripples is -1: that means that there can be only one ripple for keyboard, which isn't in line with native implementation, however, KeyEvent doesn't provide any id, so it would be hard
            _createRipple(
              id: -1,
              center: center,
              maxRadius: _computeMaxRadius(box.size, center),
            );
            widget.onTap?.call();
          }
          if (event is KeyUpEvent) {
            widget.statesController?.update(.pressed, false);
            _stopRipple(-1);
          }
          return .handled;
        }
        return .ignored;
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            widget.statesController?.update(.hovered, true);
            hovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            widget.statesController?.update(.hovered, false);
            hovered = false;
          });
        },
        child: Listener(
          onPointerMove: _handlePointerMove,
          onPointerDown: _handlePointerDown,
          onPointerCancel: _handlePointerUpCancel,
          onPointerUp: _handlePointerUpCancel,
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                widget.child,
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        for (final ripple in ripples.values) ...[
                          ripple.progressController,
                          ripple.opacityController,
                        ],
                      ]),
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _RipplePainter(
                            backgroundColor: hovered
                                ? stateLayerColor.withAlpha(20)
                                : focused
                                ? stateLayerColor.withAlpha(26)
                                : null,
                            opacityCurve: widget.opacityCurve,
                            progressCurve: widget.progressCurve,
                            ripples: ripples.values,
                            rippleColor: stateLayerColor.withAlpha(26),
                          ),
                          size: Size.infinite,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  const _RipplePainter({
    required this.ripples,
    required this.rippleColor,
    required this.opacityCurve,
    required this.progressCurve,
    required this.backgroundColor,
  });

  final Color rippleColor;
  final Color? backgroundColor;
  final Iterable<Ripple> ripples;
  final Curve opacityCurve;
  final Curve progressCurve;

  @override
  void paint(Canvas canvas, Size size) {
    if (ripples.isEmpty && backgroundColor == null) return;
    final paint = Paint();

    if (backgroundColor != null) {
      canvas.drawColor(backgroundColor!, .srcOver);
    }

    for (final ripple in ripples) {
      paint.color = rippleColor.withValues(
        alpha:
            rippleColor.a *
            opacityCurve.transform(ripple.opacityController.value),
      );

      canvas.drawCircle(
        ripple.center,
        ripple.maxRadius *
            progressCurve.transform(ripple.progressController.value),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    if (oldDelegate.backgroundColor != backgroundColor) return true;
    if (oldDelegate.ripples != ripples) return true;

    return false;
  }
}
