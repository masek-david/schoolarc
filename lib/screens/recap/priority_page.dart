import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/priority_model.dart';

class PriorityPage extends StatefulWidget {
  const PriorityPage({
    super.key,
    required this.exams,
    required this.hws,
  });

  final List<Homework> hws;
  final List<Exam> exams;

  @override
  State<PriorityPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<PriorityPage> {
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

    final priorities = List.generate(4, (index) => 0);

    for (var element in widget.hws) {
      priorities[element.priority.index]++;
    }
    for (var element in widget.exams) {
      priorities[element.priority.index]++;
    }

    int mostPickedIndex = 0;
    int maxY = 0;
    for (int i = 0; i < 4; i++) {
      if (priorities[i] > maxY) {
        maxY = priorities[i];
        mostPickedIndex = i;
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
              'How hard did you find your homework and exams?',
              style: text.headlineMedium,
            ),
          ),
          const SizedBox(height: 32),
          _animatedText(
            2,
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: BarChart(
                duration: const Duration(seconds: 1),
                BarChartData(
                  maxY: maxY.toDouble(),
                  barGroups: List.generate(
                    4,
                    (index) {
                      return BarChartGroupData(
                        showingTooltipIndicators: [0],
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: visibleIndex >= 2 ? priorities[index].toDouble() : 0,
                            width: 16,
                            color: TaskPriority(index).getColor(context),
                          )
                        ],
                      );
                    },
                  ),
                  // numbers on the top of the bars
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.transparent,
                      tooltipMargin: 0,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.toInt().toString(),
                          Theme.of(context).textTheme.labelMedium!,
                        );
                      },
                    ),
                  ),
                  // axis text - names of subjects
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
                        getTitlesWidget: (value, meta) => const SizedBox.shrink(),
                        reservedSize: 48,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            space: 12,
                            child: Text(
                              TaskPriority(value.toInt()).name,
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
                    text: 'You assigned the priority ',
                    style: text.bodyLarge,
                  ),
                  TextSpan(
                    text: TaskPriority(mostPickedIndex).name,
                    style: text.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TaskPriority(mostPickedIndex).getColor(context),
                    ),
                  ),
                  TextSpan(
                    text: ' more than others.',
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
