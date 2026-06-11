import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/screens/recap/recap.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';

class RecapDaysPage extends StatelessWidget {
  const RecapDaysPage({
    super.key,
    required this.recapData,
    required this.next,
  });

  final RecapData recapData;
  final void Function() next;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // monday is 0
    int busiestDayIndex = 0;
    int maxY = 0;
    for (int i = 0; i < 7; i++) {
      if (recapData.days[i] > maxY) {
        maxY = recapData.days[i];
        busiestDayIndex = i;
      }
    }

    final curve = SpatialMotion.fast.curve;

    return AnimatedPage(
      duration: const Duration(milliseconds: 800),
      itemDelay: const Duration(milliseconds: 800),
      overlayButton: IconButtonM3E.tonal(
        width: .wide,
        size: .large,
        icon: const Icon(Icons.keyboard_arrow_right_rounded),
        onPressed: next,
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
              child: Text(context.loc.recapHardestDay),
            );
          },
        ),
        AnimatedItem(
          spacing: 32,
          builder: (isShown) {
            final height = 300.0;

            if (recapData.needsMoreData) {
              return Text(
                context.loc.recapNotEnoughData,
                style: context.txt.titleMedium,
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: context.col.surfaceContainer,
                borderRadius: .circular(32),
              ),
              padding: const .fromLTRB(32, 24, 32, 16),
              height: height,
              child: LineChart(
                duration: SpatialMotion.fast.duration,
                curve: SpatialMotion.fast.curve,
                LineChartData(
                  maxY: maxY.toDouble(),
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      isStrokeCapRound: true,
                      preventCurveOverShooting: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 10,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(40),
                      ),
                      spots: List.generate(
                        recapData.days.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          recapData.days[index].toDouble(),
                        ),
                      ).toList(),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          // it should show only for whole numbers
                          if ((value.round() - value).abs() >
                              0.00000000000001) {
                            return const SizedBox.shrink();
                          }

                          return SideTitleWidget(
                            meta: meta,
                            space: 12,
                            child: Text(
                              DateFormat.E(context.locale.languageCode).format(
                                // this week was begining on monday, thats why i use it
                                DateTime(2024, 7, value.toInt() + 1),
                              ),
                              style: text.labelLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            );
          },
        ),
        AnimatedItem(
          spacing: 32,
          builder: (isShown) {
            if (recapData.needsMoreData) {
              return const SizedBox.shrink();
            }

            return RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: context.loc.recapBusiestDayStart,
                    style: text.headlineSmall,
                  ),
                  TextSpan(
                    text: DateFormat.EEEE(context.locale.languageCode)
                        .format(
                          // this week was begining on monday, thats why i use it
                          DateTime(2024, 7, busiestDayIndex.toInt() + 1),
                        )
                        .toLowerCase(),
                    style: text.displaySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextSpan(
                    text: context.loc.recapBusiestDayEnd(
                      (busiestDayIndex + 1).toString(),
                    ),
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
