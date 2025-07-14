import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/l10n/app_localizations.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/screens/tutorial/pages/tutorial_extensions.dart';
import 'package:school_manager/screens/tutorial/pages/tutorial_interactions.dart';
import 'package:school_manager/screens/tutorial/pages/tutorial_priorities.dart';
import 'package:school_manager/screens/tutorial/pages/tutorial_subjects.dart';
import 'package:school_manager/screens/tutorial/pages/tutorial_welcome.dart';
import 'package:school_manager/screens/tutorial/pages/tutorial_basics.dart';
import 'package:school_manager/screens/tutorial/pages/tutorial_end.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

Subject exampleSubject(AppLocalizations loc) => Subject(
  name: loc.exampleSubjectName1,
  shortcut: loc.exampleSubjectShort1,
  id: '',
  bakaId: '',
  timestamp: DateTime.now(),
  isDeleted: false,
  order: 0,
);
Homework exampleHw(AppLocalizations loc) => Homework(
  subject: exampleSubject(loc),
  text: loc.homeworks(1),
  deadline: DateTime.now().add(const Duration(days: 1)),
  isCompleted: false,
  priority: TaskPriority(0),
  id: '',
  description: null,
  timestamp: DateTime.now(),
  isDeleted: false,
  order: 0,
);
Exam exampleExam(AppLocalizations loc) => Exam(
  subject: exampleSubject(loc),
  text: loc.exams(1),
  deadline: DateTime.now().add(const Duration(days: 1)),
  isCompleted: false,
  priority: TaskPriority(0),
  id: '',
  description: null,
  timestamp: DateTime.now(),
  isDeleted: false,
  order: 0,
);

class Tutorial extends StatelessWidget {
  Tutorial({super.key, required this.onEnd});

  final void Function() onEnd;
  final _controller = PageController();

  late final pages = [
    const TutorialWelcome(),
    const TutorialBasics(),
    const TutorialPriorities(),
    const TutorialSubjects(),
    const TutorialInteractions(),
    const TutorialExtensions(),
    TutorialEnd(onEnd: onEnd),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SlidableAutoCloseBehavior(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: TextButton(
              onPressed: onEnd,
              child: Text(context.loc.skip),
            ),
            backgroundColor: Colors.transparent,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
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
                  dotColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                count: pages.length,
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
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    if (index == pages.length - 1) {
                      return pages.last;
                    }

                    return Scaffold(
                      body: pages[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
