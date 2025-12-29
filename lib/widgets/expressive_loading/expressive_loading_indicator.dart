import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:m3_expressive_shapes/m3_expressive_shapes.dart';
import 'package:m3_expressive_shapes/shapes/_shapes.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class MyExpressiveLoadingIndicator extends StatefulWidget {
  const MyExpressiveLoadingIndicator({
    super.key,
    this.progress,
    this.size = 48,
    this.color,
    this.shown = true,
    this.padding = 0,
    this.useHaptics = false,
  });

  final double? progress;
  final double size;
  final Color? color;
  final bool shown;
  final bool useHaptics;
  final double padding;

  factory MyExpressiveLoadingIndicator.big({
    bool shown = true,
    bool useHaptics = true,
  }) {
    return MyExpressiveLoadingIndicator(
      size: 72,
      padding: 16,
      shown: shown,
      useHaptics: useHaptics,
    );
  }

  @override
  State<MyExpressiveLoadingIndicator> createState() =>
      _MyExpressiveLoadingIndicatorState();
}

class _MyExpressiveLoadingIndicatorState extends State<MyExpressiveLoadingIndicator>
    with TickerProviderStateMixin {
  static final List<RoundedPolygon> shapes = [
    MaterialShapes.softBurst,
    MaterialShapes.cookie9,
    MaterialShapes.pentagon,
    MaterialShapes.pill,
    MaterialShapes.sunny,
    MaterialShapes.cookie4,
    MaterialShapes.oval,
  ];

  late final AnimationController _globalRotationController;
  late final AnimationController _morphController;
  late final AnimationController _appearController;
  int shapeIndex = 0;
  Timer? morphTimer;

  // Duration for one rotation
  static const int _globalRotationDurationMs = 4666;
  // How often the morph happens
  static const int _morphIntervalMs = 650;
  // How much should it rotate during morph
  static const double _morphRotation = pi / 2;

  final _springSimulation = SpringSimulation(
    SpringDescription.withDampingRatio(ratio: 0.6, stiffness: 50.0, mass: 1.0),
    0.0,
    1.0,
    0,
    // snapToEnd: true,
  );

  @override
  void initState() {
    _globalRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _globalRotationDurationMs),
    );

    _morphController = AnimationController(vsync: this);
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _appearController.animateTo(1, curve: Curves.decelerate);

    if (widget.progress == null) {
      startAnimation();
    }
    super.initState();
  }

  @override
  void dispose() {
    morphTimer?.cancel();
    _globalRotationController.dispose();
    _morphController.dispose();
    _appearController.dispose();

    super.dispose();
  }

  void startAnimation() {
    _globalRotationController.repeat();

    startMorphAnimation();

    morphTimer = Timer.periodic(
      const Duration(milliseconds: _morphIntervalMs),
      (timer) {
        if (widget.useHaptics) {
          vibrate.medium();
        }
        startMorphAnimation();
      },
    );
  }

  void resetAnimation() {
    _globalRotationController.reset();

    shapeIndex = 0;
    _morphController.reset();

    morphTimer?.cancel();
  }

  void startMorphAnimation() {
    shapeIndex++;
    _morphController.animateWith(_springSimulation);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.progress == null) {
      if (!_globalRotationController.isAnimating && widget.shown) {
        startAnimation();
      }
    } else {
      if (_globalRotationController.isAnimating) {
        resetAnimation();
      }
    }

    if (widget.shown) {
      if (_appearController.value == 0 ||
          _appearController.status == .reverse) {
        _appearController.animateTo(1, curve: Curves.decelerate);
      }
    } else {
      if (_appearController.value == 1 ||
          _appearController.status == .forward) {
        _appearController.animateBack(0, curve: Curves.decelerate).then(
          (value) {
            resetAnimation();
          },
        );
      }
    }

    return AnimatedBuilder(
      animation: Listenable.merge(
        [_globalRotationController, _morphController, _appearController],
      ),
      builder: (context, _) {
        late final double angle;
        late final ShapeBorder shape;
        if (widget.progress != null) {
          // Loading animation for pull down refresh
          angle = -widget.progress! * pi * 2;

          shape = ShapeBorder.lerp(
            RoundedPolygonBorder(polygon: MaterialShapes.circle),
            RoundedPolygonBorder(polygon: shapes[0]),
            widget.progress!,
          )!;
        } else {
          angle =
              _globalRotationController.value * pi * 2 +
              (shapeIndex + _morphController.value) * _morphRotation;

          shape = ShapeBorder.lerp(
            RoundedPolygonBorder(polygon: shapes[shapeIndex % shapes.length]),
            RoundedPolygonBorder(
              polygon: shapes[(shapeIndex + 1) % shapes.length],
            ),
            _morphController.value,
          )!;
        }
        final scale = 1 + ((0.5 - (_morphController.value - 0.5).abs()) * 0.3);

        return SizedBox(
          height: (widget.size + widget.padding * 2) * _appearController.value,
          child: Transform.scale(
            scale: _appearController.value + 0.1,
            child: Transform.rotate(
              angle: angle,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: ShapeDecoration(
                    color: widget.color ?? context.col.primary,
                    shape: shape,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
