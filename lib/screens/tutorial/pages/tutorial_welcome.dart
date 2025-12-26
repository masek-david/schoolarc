import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/widgets/animated_shape.dart';

class TutorialWelcome extends ConsumerWidget {
  const TutorialWelcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned(
          right: -100,
          top: -30,
          width: 350,
          height: 350,
          child: Opacity(
            opacity: isDark ? 0.3 : 0.8,
            child: const AnimatedShape(
              text: '',
              excludeShapes: false,
              secondsBeforeShapeChange: 3,
              reactive: false,
              secondsForOneRotation: -50,
            ),
          ),
        ),
        Positioned(
          left: -300,
          bottom: -300,
          width: 700,
          height: 700,
          child: Opacity(
            opacity: isDark ? 0.6 : 1,
            child: const AnimatedShape(
              text: '',
              excludeShapes: false,
              secondsBeforeShapeChange: 5,
              reactive: false,
              secondsForOneRotation: 80,
            ),
          ),
        ),
        AnimatedPage(
          padding: const EdgeInsetsGeometry.all(32),
          children: [
            AnimatedItem(
              transition: false,
              builder: (isShown) => Padding(
                padding: const EdgeInsets.only(top: 90, bottom: 30),
                child: AnimatedDefaultTextStyle(
                  duration: Durations.extralong4,
                  curve: Curves.decelerate,
                  style: robotoSerif(
                    size: 50,
                    color: Theme.of(context).colorScheme.tertiary,
                    width: isShown ? 150 : 50,
                    weight: isShown ? 900 : 100,
                    grade: -50,
                  ),
                  child: Text(
                    context.loc.welcome,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            AnimatedItem(
              builder: (isShown) => Text(
                context.loc.tutorialIntro,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
