import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';

class DaysPage extends StatefulWidget {
  const DaysPage({
    super.key,
    required this.exams,
    required this.hws,
  });

  final List<Homework> hws;
  final List<Exam> exams;

  @override
  State<DaysPage> createState() => _DaysPageState();
}

class _DaysPageState extends State<DaysPage> {
  int visibleIndex = 0;

  @override
  void initState() {
    super.initState();
    _showGradually();
  }

  Future<void> _showGradually() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        setState(() {
          visibleIndex = 1;
        });
      },
    );
    for (int i = 2; i <= 4; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          visibleIndex = i;
        });
      }
    }
  }

  Widget _animatedText(int index, Widget child, {EdgeInsets? margin}) {
    return AnimatedOpacity(
      opacity: visibleIndex >= index ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      child: Padding(padding: margin ?? EdgeInsets.zero, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final days = List.generate(
      7,
      (index) => 0,
    );
    for (var element in widget.hws) {
      days[element.deadline.weekday - 1]++;
    }
    for (var element in widget.exams) {
      days[element.deadline.weekday - 1]++;
    }

    int busiestDayIndex = 0;
    int maxY = 0;
    for (int i = 0; i < 7; i++) {
      if (days[i] > maxY) {
        maxY = days[i];
        busiestDayIndex = i;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _animatedText(
            1,
            Text(
              'What day was usually the hardest?',
              style: text.headlineMedium,
            ),
          ),
          const SizedBox(height: 32),
          _animatedText(
            2,
            Container(
              height: 300,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: LineChart(
                duration: const Duration(seconds: 1),
                LineChartData(
                  maxY: maxY.toDouble(),
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      isStrokeCapRound: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 6,
                      belowBarData: BarAreaData(
                        show: true,
                        color:
                            Theme.of(context).colorScheme.primary.withAlpha(60),
                      ),
                      dotData: const FlDotData(show: false),
                      spots: List.generate(
                        days.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          visibleIndex >= 2 ? days[index].toDouble() : 0,
                        ),
                      ).toList(),
                    ),
                  ],
                  // axis text - names of days
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            const SizedBox.shrink(),
                        reservedSize: 36,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
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
                              DateFormat.E().format(
                                // this week was begining on monday, thats why i use it
                                DateTime(2024, 7, value.toInt() + 1),
                              ),
                              style: text.labelLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
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
            ),
          ),
          const SizedBox(height: 32),
          _animatedText(
            3,
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'On average, ',
                    style: text.bodyLarge,
                  ),
                  TextSpan(
                    text: DateFormat.EEEE()
                        .format(
                          // this week was begining on monday, thats why i use it
                          DateTime(2024, 7, busiestDayIndex.toInt() + 1),
                        )
                        .toLowerCase(),
                    style: text.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextSpan(
                    text: ' was your busiest day.',
                    style: text.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
