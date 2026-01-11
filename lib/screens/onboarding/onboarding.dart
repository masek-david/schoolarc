import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schoolarc/screens/onboarding/onboarding_end.dart';
import 'package:schoolarc/screens/onboarding/onboarding_extensions.dart';
import 'package:schoolarc/screens/onboarding/onboarding_restore_data.dart';
import 'package:schoolarc/screens/onboarding/onboarding_welcome.dart';
import 'package:schoolarc/screens/tutorial/tutorial.dart';
import 'package:schoolarc/utils/globals.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key, required this.closeOnboarding});

  /// We cant use navigator.pop(), as the onboarding is displayed
  /// as an overlay (so it can have the animation)
  final void Function() closeOnboarding;

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int pageIndex = settings.get(.onboardingProgress) ?? 0;
  bool transparent = false;
  bool isNewUser = true;

  void makeTransparent() {
    setState(() {
      transparent = true;
    });
  }

  void next({int by = 1}) {
    final newPageIndex = pageIndex + by;
    if (newPageIndex >= 0 && newPageIndex <= 3) {
      setState(() {
        pageIndex = newPageIndex;
      });
      settings.save(.onboardingProgress, newPageIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = switch (pageIndex) {
      0 => OnboardingWelcome(
        newUser: () {
          next(by: 2);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Tutorial()),
          );
        },
        returningUser: () {
          isNewUser = false;
          next();
        },
      ),
      1 => OnboardingRestoredata(next: next),
      2 => OnboardingExtensions(next: next, isNewUser: isNewUser),
      _ => OnboardingEnd(
        onEnd: () {
          settings.save(.onboardingProgress, null);
          widget.closeOnboarding();
        },
        makeTransparent: makeTransparent,
      ),
    };

    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: transparent ? Colors.transparent : null,
        appBar: AppBar(
          centerTitle: false,
          title: kDebugMode
              ? TextButton(
                  onPressed: widget.closeOnboarding,
                  child: const Text('x'),
                )
              : null,
          actions: kDebugMode
              ? [
                  IconButton(
                    onPressed: () => next(by: -1),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    onPressed: () => next(),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ]
              : null,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                switchInCurve: Curves.decelerate,
                switchOutCurve: Curves.decelerate,
                duration: const Duration(milliseconds: 800),
                child: page,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
