import 'package:flutter/material.dart';
import 'package:m3_expressive_shapes/rounded_polygon_border.dart';
import 'package:m3_expressive_shapes/shapes/material_shapes.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/screens/recap/recap_screen.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';

class RecapPriorityPage extends StatefulWidget {
  const RecapPriorityPage({
    super.key,
    required this.recapData,
    required this.next,
  });

  final RecapData recapData;
  final void Function() next;

  @override
  State<RecapPriorityPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<RecapPriorityPage> {
  int chartVisibleIndex = -1;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _showGradually(),
    );
  }

  Future<void> _showGradually() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (!mounted) return;
        setState(() {
          chartVisibleIndex = 1;
        });
      },
    );
    for (int i = 2; i <= 4; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          chartVisibleIndex = i;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final curve = SpatialMotion.fast.curve;

    int mostPickedIndex = 0;
    int maxCount = 0;

    for (int i = 0; i < 4; i++) {
      if (widget.recapData.priorities[i] > maxCount) {
        maxCount = widget.recapData.priorities[i];
        mostPickedIndex = i;
      }
    }

    return AnimatedPage(
      duration: const Duration(milliseconds: 800),
      itemDelay: const Duration(milliseconds: 800),
      children: [
        AnimatedItem(
          spacing: 48,
          builder: (isShown) {
            return AnimatedDefaultTextStyle(
              style: googleSansFlex(
                size: 52,
                width: isShown ? 40 : 150,
                roundness: 100,
                weight: isShown ? 500 : 1000,
                color: context.col.onSurface,
              ),
              curve: curve,
              duration: const Duration(milliseconds: 800),
              child: const Text('Which priority did you use the most?'),
            );
          },
        ),
        AnimatedItem(
          spacing: 32,
          builder: (isShown) {
            final height = 300.0;
            final columnWidth = 60.0;
            final outerPadding = 8.0;
            final innerPadding = 4.0;

            if (maxCount == 0) {
              return Text(
                ' There isnt\'t enough data to show :( . Keep using the app!',
                style: context.txt.titleMedium,
              );
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  chartVisibleIndex = -1;
                  Future.delayed(
                    const Duration(milliseconds: 300),
                    () => _showGradually(),
                  );
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: context.col.surfaceContainer,
                  borderRadius: .circular(columnWidth / 2 + outerPadding),
                ),
                padding: .fromLTRB(outerPadding, 0, outerPadding, outerPadding),
                height: height,
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  crossAxisAlignment: .end,
                  children: List.generate(
                    4,
                    (index) {
                      final count = widget.recapData.priorities[index];

                      return AnimatedContainer(
                        duration: SpatialMotion.fast.duration,
                        curve: SpatialMotion.fast.curve,
                        height: chartVisibleIndex >= index
                            ? ((height + outerPadding) - 2 * outerPadding) *
                                      (count / maxCount) -
                                  outerPadding
                            : columnWidth,
                        width: columnWidth,
                        decoration: BoxDecoration(
                          color: TaskPriority(index).getContainerColor(context),
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        padding: .all(innerPadding),
                        child: Align(
                          alignment: .topCenter,
                          child: Container(
                            width: columnWidth - 2 * innerPadding,
                            height: columnWidth - 2 * innerPadding,
                            decoration: ShapeDecoration(
                              color: TaskPriority(
                                index,
                              ).getColor(context),
                              shape: RoundedPolygonBorder(
                                polygon: MaterialShapes.sunny,
                              ),
                            ),
                            alignment: .center,
                            child: Text(
                              widget.recapData.priorities[index].toString(),
                              style: googleSansFlex(
                                size: 18,
                                width: 60,
                                roundness: 100,
                                weight: 800,
                                color: TaskPriority(index).getOnColor(context),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedItem(
          spacing: 32,
          builder: (isShown) {
            if (maxCount == 0) {
              return const SizedBox.shrink();
            }

            return RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'You assigned the priority ',
                    style: text.headlineSmall,
                  ),
                  TextSpan(
                    text: TaskPriority(mostPickedIndex).name(context),
                    style: text.displaySmall!.copyWith(
                      color: TaskPriority(mostPickedIndex).getColor(context),
                    ),
                  ),
                  TextSpan(
                    text: ' more than the others.',

                    style: text.headlineSmall,
                  ),
                ],
              ),
            );
          },
        ),
        AnimatedItem(
          spacing: 48,
          builder: (isShown) {
            return Row(
              mainAxisAlignment: .end,
              children: [
                IconButtonM3E.tonal(
                  width: .wide,
                  size: .large,
                  icon: const Icon(Icons.keyboard_arrow_right_rounded),
                  onPressed: widget.next,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
