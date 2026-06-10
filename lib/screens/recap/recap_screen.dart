import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/m3e/buttons/button_m3e.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/screens/recap/pages/recap_count_page.dart';
import 'package:schoolarc/screens/recap/pages/recap_days_page.dart';
import 'package:schoolarc/screens/recap/pages/recap_end_page.dart';
import 'package:schoolarc/screens/recap/pages/recap_priority_page.dart';
import 'package:schoolarc/screens/recap/pages/recap_subjects_page.dart';
import 'package:schoolarc/screens/recap/recap.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/animated_shape.dart';

// works only if the school year started last year
bool _isInThisSchoolYear(Date date) {
  final today = Date.today();
  return date.isAfter(Date(today.year - 1, 8, 31)) &&
      date.isBefore(Date(today.year, 7, 8));
}

class RecapScreen extends ConsumerStatefulWidget {
  const RecapScreen({super.key});

  @override
  ConsumerState<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends ConsumerState<RecapScreen> {
  final _controller = PageController();

  void next() {
    vibrate.medium();
    _controller.nextPage(
      duration: SpatialMotion.slow.duration,
      curve: SpatialMotion.slow.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hws = ref
        .watch(hwProvider)
        .values
        .where(
          (element) => _isInThisSchoolYear(element.date) && !element.isDeleted,
        )
        .toList();
    final exams = ref
        .watch(examProvider)
        .values
        .where(
          (element) => _isInThisSchoolYear(element.date) && !element.isDeleted,
        )
        .toList();

    final isDark = context.isDark;

    final recapData = RecapData.generate(
      exams: exams,
      hws: hws,
      // TODO
      name: 'David',
      year: '2025-26',
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              right: -100,
              top: -30,
              width: 350,
              height: 350,
              child: AnimatedShape(
                text: '',
                excludeShapes: false,
                secondsBeforeShapeChange: 3,
                reactive: false,
                secondsForOneRotation: -50,
                firstColor: context.col.primaryContainer.withAlpha(
                  isDark ? 10 : 50,
                ),
                secondColor: context.col.secondaryContainer.withAlpha(
                  isDark ? 10 : 50,
                ),
              ),
            ),
            Positioned(
              left: -300,
              bottom: -300,
              width: 700,
              height: 700,
              child: AnimatedShape(
                text: '',
                excludeShapes: false,
                secondsBeforeShapeChange: 5,
                reactive: false,
                secondsForOneRotation: 80,
                firstColor: context.col.primaryContainer.withAlpha(
                  isDark ? 30 : 80,
                ),
                secondColor: context.col.tertiaryContainer.withAlpha(
                  isDark ? 30 : 60,
                ),
              ),
            ),
            PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: _controller,
              itemCount: 5,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return RecapCountPage(next: next, recapData: recapData);
                  case 1:
                    return RecapSubjectsPage(next: next, recapData: recapData);
                  case 2:
                    return RecapDaysPage(next: next, recapData: recapData);
                  case 3:
                    return RecapPriorityPage(next: next, recapData: recapData);
                  case 4:
                    return RecapEndPage(recapData: recapData);
                }
                return const Placeholder();
              },
            ),
            Align(
              alignment: .topLeft,
              child: SafeArea(
                child: ButtonM3E.text(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.loc.exit),
                ),
              ),
            ),
            if (kDebugMode)
              Align(
                alignment: .topRight,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: .end,
                    children: [
                      IconButtonM3E(
                        onPressed: () => _controller.previousPage(
                          duration: const Duration(microseconds: 1),
                          curve: Curves.linear,
                        ),
                        icon: const Icon(Icons.arrow_left_rounded),
                      ),
                      IconButtonM3E(
                        onPressed: () => _controller.nextPage(
                          duration: const Duration(microseconds: 1),
                          curve: Curves.linear,
                        ),
                        icon: const Icon(Icons.arrow_right_rounded),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
