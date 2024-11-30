import 'package:flutter/material.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_bakalari.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_end.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_priorities.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_welcome.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_homeworks.dart';
import 'package:school_manager/screens/welcome_screen/screens/welcome_screen_exams.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox.shrink(),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Skip'),
            ),
          ],
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
              count: 6,
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
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return const WelcomeScreenWelcome();
                    case 1:
                      return const WelcomeScreenPriorities();
                    case 2:
                      return const WelcomeScreenHomeworks();
                    case 3:
                      return const WelcomeScreenExams();
                    case 4:
                      return const WelcomeScreenBakalari();
                    case 5:
                      return const WelcomeScreenEnd();
                    default:
                      return null;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
