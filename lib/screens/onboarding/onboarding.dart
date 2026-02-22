import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schoolarc/screens/onboarding/onboarding_android_widget.dart';
import 'package:schoolarc/screens/onboarding/onboarding_end.dart';
import 'package:schoolarc/screens/onboarding/onboarding_extensions.dart';
import 'package:schoolarc/screens/onboarding/onboarding_notifications.dart';
import 'package:schoolarc/screens/onboarding/onboarding_restore_data.dart';
import 'package:schoolarc/screens/onboarding/onboarding_welcome.dart';
import 'package:schoolarc/screens/tutorial/tutorial.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/notifications/notification_sender.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key, required this.closeOnboarding});

  /// We cant use navigator.pop(), as the onboarding is displayed
  /// as an overlay (so it can have the exit animation)
  final void Function() closeOnboarding;

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int pageIndex = settings.get(.onboardingProgress) ?? 0;
  bool transparent = false;
  bool isNewUser = true;

  @override
  void initState() {
    settings.save(.onboardingProgress, 0);

    super.initState();
  }

  void makeTransparent() {
    setState(() {
      transparent = true;
    });
  }

  void next({int by = 1}) {
    final newPageIndex = pageIndex + by;
    if (newPageIndex >= 0 && newPageIndex <= pages.length - 1) {
      setState(() {
        pageIndex = newPageIndex;
      });
      settings.save(.onboardingProgress, newPageIndex);
    }
  }

  late final pages = [
    OnboardingWelcome(
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
    OnboardingRestoredata(next: next),
    OnboardingExtensions(next: next, isNewUser: isNewUser),
    if (NotificationSender.isCompatiblePlatform())
      OnboardingNotifications(next: next),
    if (!kIsWeb && Platform.isAndroid) OnboardingAndroidWidget(next: next),
    OnboardingEnd(
      onEnd: () {
        settings.save(.onboardingProgress, null);
        widget.closeOnboarding();
      },
      makeTransparent: makeTransparent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                switchInCurve: Curves.decelerate,
                switchOutCurve: Curves.decelerate,
                duration: const Duration(milliseconds: 800),
                child: pages[pageIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
