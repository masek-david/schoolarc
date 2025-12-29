import 'dart:math';

import 'package:flutter/material.dart';
import 'package:m3_expressive_shapes/m3_expressive_shapes.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/utils/globals.dart';

class PriorityPickerExpressive extends StatefulWidget {
  const PriorityPickerExpressive({
    super.key,
    required this.selectedPriority,
    required this.onSelected,
  });

  final int selectedPriority;
  final void Function(int value) onSelected;

  @override
  State<PriorityPickerExpressive> createState() =>
      _PriorityPickerExpressiveState();
}

class _PriorityPickerExpressiveState extends State<PriorityPickerExpressive>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late double rawProgress = widget.selectedPriority.toDouble();

  final shapeSize = 40.0;
  final shapes = [
    MaterialShapes.circle,
    MaterialShapes.cookie4,
    MaterialShapes.cookie6,
    MaterialShapes.cookie9,
  ];

  void selectPriority(int newPriority) {
    vibrate.medium();
    widget.onSelected(newPriority);
  }

  ShapeBorder getShape(double value) {
    final leftSnap = (rawProgress * 3).floor();
    final distance = (rawProgress * 3) - leftSnap;

    if (leftSnap >= 3) {
      return RoundedPolygonBorder(polygon: shapes[3]);
    }

    return ShapeBorder.lerp(
      RoundedPolygonBorder(polygon: shapes[leftSnap]),
      RoundedPolygonBorder(polygon: shapes[leftSnap + 1]),
      distance,
    )!;
  }

  Color getColor(double value) {
    final leftSnap = (rawProgress * 3).floor();
    final distance = (rawProgress * 3) - leftSnap;

    return Color.lerp(
      TaskPriority(leftSnap).getColor(context),
      TaskPriority(leftSnap + 1).getColor(context),
      distance,
    )!;
  }

  void animateTo(double value, {Duration? duration, Curve? curve}) {
    _controller.value = rawProgress;
    _controller.animateTo(value,
        duration: duration, curve: curve ?? Curves.linear);
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _controller.addListener(
      () {
        if (mounted) {
          setState(() {
            rawProgress = _controller.value;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priority = TaskPriority(widget.selectedPriority);

    final sliderBackgroundColor = List.generate(
      4,
      (index) {
        final priority = TaskPriority(index);
        return widget.selectedPriority == index
            ? priority.getContainerColor(context)
            : priority.getSurfaceColor(context);
      },
    );

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: Text(
                priority.name(context),
                style: TextStyle(
                  color: priority.getColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: shapeSize / 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        3,
                        (index) {
                          return Expanded(
                            child: AnimatedContainer(
                              curve: Curves.decelerate,
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: 8,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  sliderBackgroundColor[index],
                                  sliderBackgroundColor[index + 1],
                                ]),
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (index) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              selectPriority(index);
                              animateTo(
                                index / 3,
                                curve: Curves.decelerate,
                                duration: const Duration(milliseconds: 300),
                              );
                            },
                            child: Container(
                              color: Colors.transparent,
                              height: shapeSize,
                              width: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  LayoutBuilder(builder: (context, constraints) {
                    final width = constraints.maxWidth - shapeSize;

                    final leftSnap = (rawProgress * 3).floor();
                    final distance = (rawProgress * 3) - leftSnap;

                    final curved = Curves.easeInOutCirc.transform(distance);
                    var progress = (leftSnap + curved) / 3;

                  // If its animating from the tap
                    if (_controller.duration ==
                        const Duration(milliseconds: 500)) {
                      progress = rawProgress;
                    }

                    return Align(
                      alignment:
                          AlignmentGeometry.directional(progress * 2 - 1, 0),
                      child: GestureDetector(
                        onHorizontalDragStart: (details) {
                          if (_controller.isAnimating) {
                            _controller.stop();
                          }
                        },
                        onHorizontalDragUpdate: (details) {
                          rawProgress += details.delta.dx / width;
                          rawProgress = rawProgress.clamp(0, 1);

                          final newPriority =
                              (rawProgress * 3).round().clamp(0, 3);
                          if (newPriority != widget.selectedPriority) {
                            selectPriority(newPriority);
                          }

                          setState(() {});
                        },
                        onHorizontalDragEnd: (details) {
                          animateTo((rawProgress * 3).round().clamp(0, 3) / 3);
                        },
                        child: SizedBox(
                          height: shapeSize,
                          width: shapeSize,
                          child: Transform.rotate(
                            angle: pi * progress * 3 * 0.5,
                            child: Container(
                              height:
                                  shapeSize - 12 + widget.selectedPriority * 3,
                              width:
                                  shapeSize - 12 + widget.selectedPriority * 3,
                              decoration: ShapeDecoration(
                                  color: getColor(progress),
                                  shape: getShape(progress)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(rawProgress.toStringAsFixed(3)),
        Slider(
          value: rawProgress,
          onChanged: (value) => setState(() {
            rawProgress = value;
          }),
        ),
      ],
    );
  }
}
