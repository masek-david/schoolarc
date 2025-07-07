
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';

class _SubjectOrder {
  _SubjectOrder({
    required this.usedTimes,
    required this.subject,
  });

  final Subject subject;
  final int usedTimes;
}

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({
    super.key,
    required this.exams,
    required this.hws,
  });

  final List<Homework> hws;
  final List<Exam> exams;

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
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

    final Map<Subject, int> subjectsMap = {};
    for (var element in widget.hws) {
      if (element.subject != null) {
        subjectsMap[element.subject!] = (subjectsMap[element.subject] ?? 0) + 1;
      }
    }
    for (var element in widget.exams) {
      if (element.subject != null) {
        subjectsMap[element.subject!] = (subjectsMap[element.subject] ?? 0) + 1;
      }
    }
    final subjects = subjectsMap.entries
        .map((e) => _SubjectOrder(subject: e.key, usedTimes: e.value))
        .toList();

    subjects.sort(
      (a, b) => b.usedTimes.compareTo(a.usedTimes),
    );
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _animatedText(
            1,
            Text(
              'Which subject was the most demanding?',
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
                  maxY: subjects.isNotEmpty
                      ? subjects[0].usedTimes.toDouble()
                      : 0,
                  barGroups: List.generate(
                    subjects.length >= 5 ? 5 : subjects.length,
                    (index) {
                      final subject = subjects[index];

                      return BarChartGroupData(
                        showingTooltipIndicators: [0],
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: visibleIndex >= 2
                                ? subject.usedTimes.toDouble()
                                : 0,
                            width: 16,
                            color: Theme.of(context).colorScheme.primary,
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
                              subjects[value.toInt()].subject.shortcut,
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
            subjects.isEmpty
                ? const Text(
                    'There aren\'t enough data to show :( . Keep using the app!')
                : RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'You assigned the subject ',
                          style: text.bodyLarge,
                        ),
                        TextSpan(
                          text: subjects[0].subject.name,
                          style: text.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
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
