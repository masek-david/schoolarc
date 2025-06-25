import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/screens/recap/count_page.dart';
import 'package:school_manager/screens/recap/days_page.dart';
import 'package:school_manager/screens/recap/final_page.dart';
import 'package:school_manager/screens/recap/priority_page.dart';
import 'package:school_manager/screens/recap/subjects_page.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

bool hasSeenRecap(){
  return settings.get(Setting.recapShownForYear) >= DateTime.now().year;
}

// returns true if it is last two weeks of school
bool isRecapDate() {
  final now = DateTime.now();

  return now.isAfter(now.copyWith(month: 6, day: 23)) &&
      now.isBefore(
        now.copyWith(month: 7, day: 8),
      );
}

bool isInThisYear(DateTime date) {
  final now = DateTime.now();
  return date.isAfter(DateTime(now.year - 1, 8, 31)) &&
      date.isBefore(
        DateTime(now.year, 7, 8),
      );
}

class RecapScreen extends ConsumerStatefulWidget {
  const RecapScreen({super.key});

  @override
  ConsumerState<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends ConsumerState<RecapScreen> {
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final hws = ref
        .watch(hwProvider)
        .values
        .where(
          (element) => isInThisYear(element.deadline) && !element.isDeleted,
        )
        .toList();
    final exams = ref
        .watch(examProvider)
        .values
        .where(
          (element) => isInThisYear(element.deadline) && !element.isDeleted,
        )
        .toList();

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Exit'),
          ),
          backgroundColor: Colors.transparent,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => _controller.previousPage(
                  duration: Durations.medium3, curve: Curves.easeInOut),
              icon: const Icon(
                Icons.keyboard_arrow_left_rounded,
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              effect: WormEffect(
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              count: 5,
            ),
            IconButton(
              onPressed: () => _controller.nextPage(
                  duration: Durations.medium3, curve: Curves.easeInOut),
              icon: const Icon(
                Icons.keyboard_arrow_right_rounded,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: 5,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return CountPage(
                        exams: exams,
                        hws: hws,
                      );
                    case 1:
                      return SubjectsPage(
                        exams: exams,
                        hws: hws,
                      );
                    case 2:
                      return DaysPage(
                        exams: exams,
                        hws: hws,
                      );
                    case 3:
                      return PriorityPage(
                        exams: exams,
                        hws: hws,
                      );
                    case 4:
                      return FinalPage();
                  }
                  return Placeholder();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
