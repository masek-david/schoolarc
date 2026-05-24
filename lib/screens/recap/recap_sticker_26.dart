import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/screens/recap/recap_screen.dart';
import 'package:schoolarc/utils/color_mapper.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';

/// 3.5 x 2 in  |  8.9 x 5.08 cm  |  336 x 192 px
class RecapSticker26 extends StatelessWidget {
  const RecapSticker26({super.key, required this.recapData});

  final RecapData recapData;

  Widget _buildCircle(
    BuildContext context, {
    required String text,
    required Color bg,
    required Color fg,
    required double size,
  }) {
    return Container(
      decoration: ShapeDecoration(shape: const CircleBorder(), color: bg),
      alignment: .center,
      child: Text(
        text,
        style: googleSansFlex(
          size: size * 0.8,
          weight: 600,
          roundness: 100,
          width: 80,
          color: fg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int maxDaysY = 0;
    for (int i = 0; i < recapData.days.length; i++) {
      if (recapData.days[i] > maxDaysY) {
        maxDaysY = recapData.days[i];
      }
    }
    int maxPriorityY = 0;
    for (int i = 0; i < recapData.priorities.length; i++) {
      if (recapData.priorities[i] > maxPriorityY) {
        maxPriorityY = recapData.priorities[i];
      }
    }

    final r1 = 35.0;
    final r2 =
        r1 * recapData.subjects[1].usedTimes / recapData.subjects[0].usedTimes;
    final r3 =
        r1 * recapData.subjects[2].usedTimes / recapData.subjects[0].usedTimes;

    final x1 = r1;
    final y1 = r1;

    final x2 = r1 + sqrt(pow(r2 + r1, 2) - pow(r1 - r2, 2));
    final y2 = r2;

    final a = r2 + r3;
    final b = r1 + r3;
    final c = r1 + r2;
    // angle between ground and P1 and P2
    final delta = asin((y2 - y1) / c);
    // angle at P1
    final alpha = acos((b * b + c * c - a * a) / (2 * b * c));
    final x3 = (r1 + r3) * sin(pi / 2 - delta - alpha) + x1;
    final y3 = (r1 + r3) * cos(pi / 2 - delta - alpha) + y1;

    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(blurRadius: 5, offset: Offset(4, 4)),
        ],
        borderRadius: BorderRadius.circular(16),
        color: context.col.surfaceContainer,
      ),
      width: 336,
      height: 192,
      padding: const .all(12),
      child: Stack(
        children: [
          Align(
            alignment: const .xy(0.76, -1),
            child: SizedBox(
              height: 50,
              child: PrettyQrView(
                decoration: PrettyQrDecoration(
                  shape: PrettyQrSmoothSymbol(
                    color: context.col.tertiary.withAlpha(150),
                  ),
                ),
                qrImage: QrImage(
                  QrCode.fromData(
                    data: recapData.encode(),
                    errorCorrectLevel: QrErrorCorrectLevel.L,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: y3 - r3,
            left: x3 - r3,
            width: r3 * 2,
            height: r3 * 2,
            child: _buildCircle(
              context,
              size: r3,
              text: recapData.subjects[2].subject.shortcut,
              bg: context.col.secondaryContainer,
              fg: context.col.onSecondaryContainer,
            ),
          ),
          Positioned(
            bottom: y2 - r2,
            left: x2 - r2,
            width: r2 * 2,
            height: r2 * 2,
            child: _buildCircle(
              context,
              size: r2,
              text: recapData.subjects[1].subject.shortcut,
              bg: context.col.tertiaryContainer,
              fg: context.col.onTertiaryContainer,
            ),
          ),
          Positioned(
            bottom: y1 - r1,
            left: x1 - r1,
            width: r1 * 2,
            height: r1 * 2,
            child: _buildCircle(
              context,
              size: r1,
              text: recapData.subjects[0].subject.shortcut,
              bg: context.col.primaryContainer,
              fg: context.col.onPrimaryContainer,
            ),
          ),
          Align(
            alignment: const .xy(1, 1),
            child: Row(
              mainAxisSize: .min,
              spacing: 16,
              children: [
                Column(
                  mainAxisSize: .min,
                  children: [
                    Text(
                      recapData.homeworksCount.toString(),
                      style: googleSansFlex(
                        size: 32,
                        weight: 700,
                        width: 131,
                        roundness: 100,
                        slant: -10,
                        color: context.col.tertiary,
                      ),
                    ),
                    Text(
                      'Homework',
                      style: googleSansFlex(
                        height: 0.2,
                        size: 14,
                        weight: 300,
                        width: 50,
                        roundness: 100,
                        color: context.col.tertiary,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: .min,
                  children: [
                    Text(
                      recapData.examsCount.toString(),
                      style: googleSansFlex(
                        size: 32,
                        weight: 700,
                        width: 131,
                        roundness: 100,
                        slant: -10,
                        color: context.col.tertiary,
                      ),
                    ),
                    Text(
                      'Exams',
                      style: googleSansFlex(
                        height: 0.2,
                        size: 14,
                        weight: 300,
                        width: 50,
                        roundness: 100,
                        color: context.col.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Align(
            alignment: const .xy(1, -1),
            child: SizedBox(
              height: 25,
              child: Opacity(
                opacity: 0.5,
                child: SvgPicture.asset(
                  'assets/schoolarc_icon.svg',
                  colorMapper: LogoColorMapper(
                    isDark: Theme.of(context).brightness == Brightness.dark,
                    primaryFixedDimColor: context.col.primaryFixedDim
                        .toARGB32(),
                    secondaryColor: context.col.secondary.toARGB32(),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const .xy(1, 0.8),
            child: SizedBox(
              width: 150,
              height: 80,
              child: LineChart(
                LineChartData(
                  lineTouchData: const LineTouchData(enabled: false),
                  maxY: maxPriorityY.toDouble(),
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      gradient: LinearGradient(
                        colors: List.generate(
                          4,
                          (index) => TaskPriority(
                            index,
                          ).getColor(context).withAlpha(140),
                        ),
                      ),
                      isCurved: true,
                      isStrokeCapRound: true,
                      preventCurveOverShooting: true,
                      barWidth: 4,
                      dotData: FlDotData(
                        checkToShowDot: (spot, barData) {
                          return spot.y == maxPriorityY;
                        },
                      ),
                      spots: List.generate(
                        recapData.priorities.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          recapData.priorities[index].toDouble(),
                        ),
                      ).toList(),
                    ),
                  ],
                  titlesData: const FlTitlesData(show: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
          Align(
            alignment: const .xy(1, 0.8),
            child: SizedBox(
              width: 150,
              height: 100,
              child: LineChart(
                LineChartData(
                  lineTouchData: const LineTouchData(enabled: false),
                  maxY: maxDaysY.toDouble(),
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      isStrokeCapRound: true,
                      preventCurveOverShooting: true,
                      color: context.col.primary.withAlpha(120),
                      barWidth: 4,
                      dotData: FlDotData(
                        checkToShowDot: (spot, barData) {
                          return spot.y == maxDaysY;
                        },
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
                  titlesData: const FlTitlesData(show: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),

          Align(
            alignment: const .xy(-1, -1.1),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'David',
                  style: googleSansFlex(
                    color: context.col.primary,
                    size: 40,
                    weight: 800,
                    roundness: 100,
                    width: 80,
                    height: 1,
                    slant: -10,
                  ),
                ),
                Text(
                  '2025-26',
                  style: googleSansFlex(
                    color: context.col.primary,
                    size: 14,
                    weight: 200,
                    width: 151,
                    slant: -10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
