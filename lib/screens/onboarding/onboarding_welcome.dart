import 'package:flutter/material.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/widgets/animated_shape.dart';

class OnboardingWelcome extends StatelessWidget {
  const OnboardingWelcome({
    super.key,
    required this.returningUser,
    required this.newUser,
  });

  final void Function() returningUser;
  final void Function() newUser;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: context.col.surface,
      child: Stack(
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
                  padding: const EdgeInsets.only(top: 72, bottom: 28),
                  child: AnimatedDefaultTextStyle(
                    duration: Durations.extralong4,
                    curve: Curves.decelerate,
                    style: robotoSerif(
                      size: 56,
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
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Text(
                    context.loc.onboardingWelcome,
                    style: googleSansFlex(size: 16, width: 120, weight: 500),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              AnimatedItem(
                builder: (isShown) => SettingTile(
                  title: context.loc.newUser,
                  subtitle: context.loc.viewTutorial,
                  isFirst: true,
                  onTap: (context) => newUser(),
                  trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                ),
              ),
              AnimatedItem(
                builder: (isShown) => SettingTile(
                  title: context.loc.returningUser,
                  subtitle: context.loc.restoreData,
                  onTap: (context) => returningUser(),
                  trailing: const Icon(Icons.login_rounded),
                  isLast: true,
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/tutorial');
              },
              child: Text(
                context.loc.privacyPolicyAgree,
                style: TextStyle(
                  fontSize: 12,
                  color: context.col.onSurface.withAlpha(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
