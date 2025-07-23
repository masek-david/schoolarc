import 'dart:math';

import 'package:flutter/material.dart';
import 'package:m3_expressive_shapes/rounded_polygon_border.dart';
import 'package:m3_expressive_shapes/shapes/_shapes.dart';
import 'package:m3_expressive_shapes/shapes/material_shapes.dart';
import 'package:schoolarc/models/priority_model.dart';

class AnimatedCheckbox extends StatelessWidget {
  const AnimatedCheckbox({
    super.key,
    required this.value,
    required this.priority,
    required this.onChanged,
    required this.scale,
    required this.rotation,
    required this.shape,
  });

  final bool value;
  final TaskPriority priority;
  final double scale;
  final double rotation;
  final RoundedPolygon shape;
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 + scale * 1.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: rotation * pi * 0.7,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.decelerate,
                  height: 24,
                  width: 24,
                  decoration: ShapeDecoration(
                    color: priority.getColor(context),
                    shape: RoundedPolygonBorder(
                      polygon: scale < 0.5 ? MaterialShapes.circle : shape,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.decelerate,
                  height: 24 - 7,
                  width: 24 - 7,
                  decoration: ShapeDecoration(
                    color: value
                        ? null
                        : Theme.of(context).colorScheme.surfaceContainerLow,
                    shape: RoundedPolygonBorder(
                      polygon: scale < 0.5 ? MaterialShapes.circle : shape,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: value,
              onChanged: (value) => onChanged(value!),
              checkColor: Theme.of(context).colorScheme.surface,
              hoverColor: Colors.transparent,
              activeColor: Colors.transparent,
              focusColor: Colors.transparent,
              fillColor: const WidgetStatePropertyAll(Colors.transparent),
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              side: WidgetStateBorderSide.resolveWith(
                (states) => const BorderSide(
                  width: 5.0,
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
