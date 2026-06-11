import 'package:flutter/material.dart';
import 'package:m3_expressive_shapes/rounded_polygon_border.dart';
import 'package:m3_expressive_shapes/shapes/material_shapes.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/screens/recap/recap.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';

class RecapSubjectsPage extends StatefulWidget {
  const RecapSubjectsPage({
    super.key,
    required this.recapData,
    required this.next,
  });

  final RecapData recapData;
  final void Function() next;

  @override
  State<RecapSubjectsPage> createState() => _RecapSubjectsPageState();
}

class _RecapSubjectsPageState extends State<RecapSubjectsPage> {
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
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        setState(() {
          chartVisibleIndex = 0;
        });
      },
    );
    for (int i = 1; i <= 4; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        vibrate.medium();
        chartVisibleIndex = i;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final curve = SpatialMotion.fast.curve;

    return AnimatedPage(
      duration: const Duration(milliseconds: 800),
      itemDelay: const Duration(milliseconds: 800),
      overlayButton: IconButtonM3E.tonal(
        width: .wide,
        size: .large,
        icon: const Icon(Icons.keyboard_arrow_right_rounded),
        onPressed: widget.next,
      ),
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
              child: Text(context.loc.recapWhichSubject),
            );
          },
        ),
        AnimatedItem(
          spacing: 32,
          builder: (isShown) {
            if (widget.recapData.needsMoreData) {
              return Text(
                context.loc.recapNotEnoughData,
                style: context.txt.titleMedium,
              );
            }

            final height = 300.0;
            final columnWidth = 60.0;
            final outerPadding = 8.0;
            final innerPadding = 4.0;

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
                    5,
                    (index) {
                      final maxCount = widget.recapData.subjects[0].usedTimes;
                      final count = widget.recapData.subjects[index].usedTimes;

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
                          color: context.col.primaryContainer,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        padding: .all(innerPadding),
                        child: Stack(
                          children: [
                            Align(
                              alignment: .bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  '${widget.recapData.subjects[index].usedTimes}x',
                                  style: googleSansFlex(size: 14, weight: 600),
                                ),
                              ),
                            ),
                            Container(
                              width: columnWidth - 2 * innerPadding,
                              height: columnWidth - 2 * innerPadding,
                              decoration: ShapeDecoration(
                                color: context.col.primary,
                                shape: RoundedPolygonBorder(
                                  polygon: MaterialShapes.sunny,
                                ),
                              ),
                              alignment: .center,
                              child: Text(
                                widget
                                    .recapData
                                    .subjects[index]
                                    .subject
                                    .shortcut,
                                style: googleSansFlex(
                                  size: 18,
                                  width: 60,
                                  roundness: 100,
                                  weight: 800,
                                  color: context.col.onPrimary,
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
          },
        ),
        AnimatedItem(
          spacing: 32,
          builder: (isShown) {
            if (widget.recapData.needsMoreData) {
              return const SizedBox.shrink();
            }

            return RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: context.loc.recapMostUsedSubjectStart,
                    style: text.headlineSmall,
                  ),
                  TextSpan(
                    text: widget.recapData.subjects[0].subject.name,
                    style: text.displaySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextSpan(
                    text: context.loc.recapMostUsedSubjectEnd,
                    style: text.headlineSmall,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
