import 'package:flutter/material.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/widgets/animated_shape.dart';

class TutorialWelcome extends StatelessWidget {
  const TutorialWelcome({
    super.key,
    required this.startTutorial,
    required this.skipTutorial,
  });

  final void Function() startTutorial;
  final void Function() skipTutorial;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
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
              isDark ? 77 : 204,
            ),
            secondColor: context.col.secondaryContainer.withAlpha(
              isDark ? 77 : 204,
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
              isDark ? 153 : 255,
            ),
            secondColor: context.col.tertiaryContainer.withAlpha(
              isDark ? 153 : 255,
            ),
          ),
        ),
        AnimatedPage(
          spacing: 2,
          children: [
            AnimatedItem(
              transition: false,
              builder: (isShown) => Padding(
                padding: const EdgeInsets.only(top: 120, bottom: 20),
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
              builder: (isShown) => Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Text(
                  context.loc.tutorialIntro,
                  style: googleSansFlex(size: 16, width: 120, weight: 500),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            AnimatedItem(
              builder: (isShown) => SettingTile(
                title: 'New user',
                subtitle: 'View tutorial',
                isFirst: true,
                onTap: (context) => startTutorial(),
                trailing: const Icon(Icons.keyboard_arrow_right_rounded),
              ),
            ),
            AnimatedItem(
              builder: (isShown) => SettingTile(
                title: 'Returning user',
                subtitle: 'Restore data',
                onTap: (context) => skipTutorial(),
                trailing: const Icon(Icons.login_rounded),
                isLast: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
