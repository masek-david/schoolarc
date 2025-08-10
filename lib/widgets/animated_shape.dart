import 'dart:async';
import 'dart:math';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3_expressive_shapes/rounded_polygon_border.dart';
import 'package:m3_expressive_shapes/shapes/material_shapes.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/roboto_serif.dart';
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
    this.shapeChangeDuration,
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
    this.shapeChangeDuration,
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
    this.shapeChangeDuration,
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
  final Duration? shapeChangeDuration;

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

  late final duration =
      widget.shapeChangeDuration ?? const Duration(milliseconds: 500);
  final curve = Curves.decelerate;
  late final _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.secondsForOneRotation.abs()));
  late final _scaleController =
      AnimationController(vsync: this, duration: duration * 0.5);

  late final shapes = widget.excludeShapes ? textShapes : MaterialShapes.values;
  int shapeIndex = 14;
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

    _scaleController.animateTo(0.95);

    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();

    super.dispose();
  }

  void changeShape() {
    if (!mounted) return;
    _scaleController.animateTo(1, duration: duration * 0.5).then(
        (_) => _scaleController.animateTo(0.95, duration: duration * 0.5));

    int random = Random().nextInt(shapes.length);
    while (random == shapeIndex) {
      random = Random().nextInt(shapes.length);
    }

    setState(() {
      shapeIndex = random;
      turns += 0.1 * (widget.secondsForOneRotation.isNegative ? -1 : 1);
    });
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
        onTapDown: widget.reactive
            ? (details) {
                _scaleController.animateTo(0.9, duration: duration * 0.5);
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
              return Transform.scale(
                scale: _scaleController.value,
                child: Stack(
                  children: [
                    AnimatedRotation(
                      duration: duration,
                      curve: curve,
                      turns: turns,
                      child: Transform.rotate(
                        angle: pi *
                            2 *
                            _rotationController.value *
                            (widget.secondsForOneRotation.isNegative ? -1 : 1),
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: duration,
                              curve: curve,
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
                                shape: RoundedPolygonBorder(
                                    polygon: shapes[shapeIndex]),
                              ),
                            ),
                            if (ref.watch(themeUseOledProvider))
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: AnimatedContainer(
                                  duration: duration,
                                  curve: curve,
                                  decoration: ShapeDecoration(
                                    shadows: [
                                      BoxShadow(
                                        blurRadius: 30,
                                        spreadRadius: -1,
                                        color: secondColor,
                                      ),
                                    ],
                                    color: Colors.black,
                                    shape: RoundedPolygonBorder(
                                        polygon: shapes[shapeIndex]),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
