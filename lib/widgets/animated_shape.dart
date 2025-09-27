import 'dart:async';
import 'dart:math';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3_expressive_shapes/rounded_polygon_border.dart';
import 'package:m3_expressive_shapes/shapes/material_shapes.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/shapes_list.dart';

class AnimatedShape extends ConsumerStatefulWidget {
  const AnimatedShape({
    super.key,
    this.size = 200,
    this.text = 'Everything done',
    this.reactive = true,
    this.secondsForOneRotation = 15,
    this.firstColor,
    this.secondColor,
    this.textColor,
    this.excludeShapes = true,
    this.secondsBeforeShapeChange,
  });

  AnimatedShape.error({
    super.key,
    this.size = 200,
    this.text = 'Error',
    this.reactive = true,
    this.secondsForOneRotation = 15,
    this.excludeShapes = true,
    this.secondsBeforeShapeChange,
    required ColorScheme scheme,
  })  : firstColor = scheme.errorContainer,
        secondColor = scheme.error,
        textColor = scheme.onErrorContainer;

  AnimatedShape.success({
    super.key,
    this.size = 200,
    this.text = 'Success',
    this.reactive = true,
    this.secondsForOneRotation = 15,
    this.excludeShapes = true,
    this.secondsBeforeShapeChange,
    required Color primary,
    required bool isDark,
  })  : firstColor = isDark
            ? const Color.fromARGB(255, 0, 107, 30).harmonizeWith(primary)
            : const Color.fromARGB(255, 174, 255, 168).harmonizeWith(primary),
        secondColor = isDark
            ? const Color.fromARGB(255, 193, 255, 225).harmonizeWith(primary)
            : const Color.fromARGB(255, 0, 255, 51).harmonizeWith(primary),
        textColor = isDark
            ? const Color.fromARGB(255, 220, 255, 210).harmonizeWith(primary)
            : const Color.fromARGB(255, 0, 54, 3).harmonizeWith(primary);

  final double size;
  final Color? firstColor;
  final Color? secondColor;
  final Color? textColor;
  final String text;
  final bool reactive;
  final int secondsForOneRotation;
  final bool excludeShapes;
  final int? secondsBeforeShapeChange;

  @override
  ConsumerState<AnimatedShape> createState() => _AnimatedShapeState();
}

class _AnimatedShapeState extends ConsumerState<AnimatedShape>
    with TickerProviderStateMixin {
  late final size = widget.size;
  late String text = widget.text;

  late Color firstColor =
      widget.firstColor ?? Theme.of(context).colorScheme.primaryContainer;
  late Color secondColor =
      widget.secondColor ?? Theme.of(context).colorScheme.tertiaryContainer;
  late Color textColor =
      widget.textColor ?? Theme.of(context).colorScheme.onTertiaryContainer;

  /// Updates every frame
  late final _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.secondsForOneRotation.abs()));

  late final shapeController = AnimationController(
      vsync: this, lowerBound: -10, upperBound: 10, value: 0);

  late final shapes = widget.excludeShapes ? textShapes : MaterialShapes.values;
  late ShapeBorder from = RoundedPolygonBorder(polygon: shapes[14]);
  late ShapeBorder _currentShape;
  late int nextShapeIndex = getRandom(14);
  bool animating = false;
  var turns = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    firstColor =
        widget.firstColor ?? Theme.of(context).colorScheme.primaryContainer;
    secondColor =
        widget.secondColor ?? Theme.of(context).colorScheme.tertiaryContainer;
    textColor =
        widget.textColor ?? Theme.of(context).colorScheme.onTertiaryContainer;
  }

  @override
  void initState() {
    super.initState();

    if (widget.secondsBeforeShapeChange != null) {
      Timer.periodic(
        Duration(seconds: widget.secondsBeforeShapeChange!),
        (timer) => changeShape(),
      );
    }

    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    shapeController.dispose();

    super.dispose();
  }

  int getRandom(int exclude) {
    int random = 0;
    do {
      random = Random().nextInt(shapes.length);
    } while (random == exclude);
    return random;
  }

  Future<void> animateTo(double value) {
    final springSimulation = SpringSimulation(
      const SpringDescription(
        mass: 1,
        stiffness: 250,
        damping: 12,
      ),
      shapeController.value, // starting position
      value, // ending position
      0, // initial velocity
    );
    return shapeController.animateWith(springSimulation);
  }

  void changeShape() {
    if (!mounted) return;
    turns += 0.1 * (widget.secondsForOneRotation.isNegative ? -1 : 1);

    if (animating) {
      from = _currentShape;
      shapeController.value = 0;
      nextShapeIndex = getRandom(nextShapeIndex);
    }
    animating = true;
    animateTo(1).then(
      (value) {
        from = _currentShape;
        nextShapeIndex = getRandom(nextShapeIndex);
        animating = false;
        shapeController.value = 0;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (text == 'Everything done') {
      text = context.loc.everythingDone;
    } else if (text == 'Success') {
      text = context.loc.success;
    } else if (text == 'Error') {
      text = context.loc.error;
    }

    return Padding(
      padding: EdgeInsets.all(size * 0.3),
      child: GestureDetector(
        onTapCancel: widget.reactive
            ? () {
                animateTo(0);
              }
            : null,
        onTapDown: widget.reactive
            ? (details) {
                HapticFeedback.lightImpact();
                if (animating) {
                  from = _currentShape;
                  nextShapeIndex = getRandom(nextShapeIndex);
                  animating = false;
                  shapeController.value = 0;
                }
                animateTo(0.2);
              }
            : null,
        onTap: widget.reactive
            ? () {
                HapticFeedback.lightImpact();
                changeShape();
              }
            : null,
        child: SizedBox(
          height: size,
          child: AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              _currentShape = ShapeBorder.lerp(
                from,
                RoundedPolygonBorder(polygon: shapes[nextShapeIndex]),
                shapeController.value,
              )!;

              return Stack(
                children: [
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.decelerate,
                    turns: turns,
                    child: Transform.rotate(
                      angle: pi *
                          2 *
                          _rotationController.value *
                          (widget.secondsForOneRotation.isNegative ? -1 : 1),
                      child: Stack(
                        children: [
                          Container(
                            decoration: ShapeDecoration(
                              shadows: [
                                BoxShadow(
                                  blurRadius: 30,
                                  spreadRadius: -1,
                                  color: secondColor,
                                ),
                              ],
                              gradient: LinearGradient(
                                stops: const [0.1, 0.9],
                                colors: [secondColor, firstColor],
                              ),
                              shape: _currentShape,
                            ),
                          ),
                          if (ref.watch(themeUseOledProvider))
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                decoration: ShapeDecoration(
                                  shadows: [
                                    BoxShadow(
                                      blurRadius: 30,
                                      spreadRadius: -1,
                                      color: secondColor,
                                    ),
                                  ],
                                  color: Colors.black,
                                  shape: _currentShape,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: size - 16,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          text,
                          maxLines: 2,
                          style: robotoSerif(
                                  size: 22,
                                  width: 50,
                                  grade: -50,
                                  weight: 500,
                                  color: textColor)
                              .copyWith(
                            shadows: [
                              Shadow(color: firstColor, blurRadius: 10)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
