import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_bakalari.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_priorities.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_subjects.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_welcome.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_homeworks.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_exams.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_end.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key, required this.onEnd});

  final void Function() onEnd;
  final _controller = PageController();

  late final pages = [
    const WelcomeScreenWelcome(),
    const WelcomeScreenHomeworks(),
    const WelcomeScreenExams(),
    const WelcomeScreenSubjects(),
    const WelcomeScreenPriorities(),
    const WelcomeScreenBakalari(),
    WelcomeScreenEnd(onEnd: onEnd),
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
            leading: const SizedBox.shrink(),
            backgroundColor: Colors.transparent,
            actions: [
              TextButton(
                onPressed: onEnd,
                child: const Text('Skip'),
              ),
            ],
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
                    if(index == pages.length - 1){
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
