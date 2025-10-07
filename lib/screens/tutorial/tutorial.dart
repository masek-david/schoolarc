import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:schoolarc/l10n/app_localizations.dart';
import 'package:schoolarc/models/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/screens/tutorial/pages/tutorial_basics.dart';
import 'package:schoolarc/screens/tutorial/pages/tutorial_end.dart';
import 'package:schoolarc/screens/tutorial/pages/tutorial_extensions.dart';
import 'package:schoolarc/screens/tutorial/pages/tutorial_interactions.dart';
import 'package:schoolarc/screens/tutorial/pages/tutorial_priorities.dart';
import 'package:schoolarc/screens/tutorial/pages/tutorial_subjects.dart';
import 'package:schoolarc/screens/tutorial/pages/tutorial_welcome.dart';
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
      isShared: false,
    );
Homework exampleHw(AppLocalizations loc) => Homework(
      subject: exampleSubject(loc),
      text: loc.homework(1),
      date: Date.today().addDays(1),
      isCompleted: false,
      priority: TaskPriority(0),
      id: '',
      description: '',
      timestamp: DateTime.now(),
      isDeleted: false,
      order: 0,
      isShared: false,
    );
Exam exampleExam(AppLocalizations loc) => Exam(
      subject: exampleSubject(loc),
      text: loc.exams(1),
      date: Date.today().addDays(1),
      isCompleted: false,
      priority: TaskPriority(0),
      id: '',
      description: '',
      timestamp: DateTime.now(),
      isDeleted: false,
      order: 0,
      isShared: false,
    );

class Tutorial extends StatefulWidget {
  const Tutorial({super.key, required this.onEnd, required this.firstTime});

  final void Function() onEnd;
  final bool firstTime;

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  final _controller = PageController();
  bool showSkip = false;

  late final pages = [
    const TutorialWelcome(),
    const TutorialBasics(),
    const TutorialPriorities(),
    const TutorialSubjects(),
    const TutorialInteractions(),
    const TutorialExtensions(),
    TutorialEnd(onEnd: widget.onEnd),
  ];

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
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: false,
            title: TextButton(
              onPressed: () {
                if (!widget.firstTime) {
                  widget.onEnd();
                } else {
                  _controller.animateToPage(5,
                      duration: Durations.long4, curve: Curves.decelerate);
                }
              },
              child: Text(!widget.firstTime
                  ? context.loc.skip
                  : showSkip
                      ? context.loc.skip
                      : context.loc.alreadyUsedApp),
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
                onDotClicked: kDebugMode
                    ? (index) => _controller.jumpToPage(index)
                    : null,
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
                  onPageChanged: (value) {
                    setState(() {
                      showSkip = value != 0;
                    });
                  },
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
