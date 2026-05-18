import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:schoolarc/l10n/app_localizations.dart';
import 'package:schoolarc/m3e/buttons/button_m3e.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/screens/tutorial/pages/tutorial_basics.dart';
import 'package:schoolarc/screens/tutorial/pages/tutorial_end.dart';
import 'package:schoolarc/screens/tutorial/pages/tutorial_interactions.dart';
import 'package:schoolarc/screens/tutorial/pages/tutorial_priorities.dart';
import 'package:schoolarc/screens/tutorial/pages/tutorial_subjects.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
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
  text: loc.homework(1),
  date: Date.today().addDays(1),
  isCompleted: false,
  priority: const TaskPriority(0),
  id: '',
  description: '',
  timestamp: DateTime.now(),
  isDeleted: false,
  order: 0,
);
Exam exampleExam(AppLocalizations loc) => Exam(
  subject: exampleSubject(loc),
  text: loc.exams(1),
  date: Date.today().addDays(1),
  isCompleted: false,
  priority: const TaskPriority(0),
  id: '',
  description: '',
  timestamp: DateTime.now(),
  isDeleted: false,
  order: 0,
);

class Tutorial extends StatefulWidget {
  const Tutorial({super.key});

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  final _controller = PageController();

  late final pages = [
    const TutorialBasics(),
    const TutorialPriorities(),
    const TutorialSubjects(),
    const TutorialInteractions(),
    const TutorialEnd(),
  ];

  void scroll({bool forward = true}) {
    if (forward) {
      _controller.nextPage(
        duration: Durations.medium3,
        curve: Curves.easeInOut,
      );
    } else {
      _controller.previousPage(
        duration: Durations.medium3,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SlidableAutoCloseBehavior(
        child: Scaffold(
          appBar: AppBar(
            leading: const SizedBox.shrink(),
            leadingWidth: 0,
            centerTitle: false,
            title: ButtonM3E.text(
              onPressed: () {
                _controller.jumpToPage(4);
              },
              child: Text(context.loc.skip),
            ),
            backgroundColor: Colors.transparent,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButtonAnimator: .scaling,
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButtonM3E(
                onPressed: () => scroll(forward: false),
                icon: const Icon(
                  Icons.keyboard_arrow_left_rounded,
                ),
              ),
              SmoothPageIndicator(
                controller: _controller,
                onDotClicked: kDebugMode
                    ? (index) => _controller.jumpToPage(index)
                    : null,
                effect: WormEffect(
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
                count: pages.length,
              ),
              IconButtonM3E(
                onPressed: scroll,
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
