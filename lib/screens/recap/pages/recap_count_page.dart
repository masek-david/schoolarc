import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/screens/recap/recap.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';

class RecapCountPage extends StatelessWidget {
  const RecapCountPage({
    super.key,
    required this.recapData,
    required this.next,
  });

  final RecapData recapData;
  final void Function() next;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final curve = SpatialMotion.fast.curve;

    return AnimatedPage(
      duration: const Duration(milliseconds: 800),
      itemDelay: const Duration(milliseconds: 800),
      overlayButton: IconButtonM3E.tonal(
        width: .wide,
        size: .large,
        icon: const Icon(Icons.keyboard_arrow_right_rounded),
        onPressed: next,
      ),
      children: [
        AnimatedItem(
          spacing: 48,
          builder: (isShown) {
            return AnimatedDefaultTextStyle(
              style: googleSansFlex(
                size: 52,
                width: isShown ? 40 : 150,
                roundness: 100,
                weight: isShown ? 500 : 1000,
                color: context.col.onSurface,
              ),
              curve: curve,
              duration: const Duration(milliseconds: 800),
              child: const Text('Another year flew by.'),
            );
          },
        ),
        AnimatedItem(
          builder: (isShown) {
            return AnimatedDefaultTextStyle(
              style: googleSansFlex(
                size: 40,
                width: isShown ? 40 : 120,
                roundness: 100,
                weight: isShown ? 300 : 500,
                color: context.col.onSurfaceVariant,
              ),
              curve: curve,
              duration: const Duration(milliseconds: 800),
              child: const Text('Now let\'s see how you did:'),
            );
          },
        ),
        AnimatedItem(
          spacing: 64,
          builder: (isShown) {
            return RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: recapData.examsCount.toString(),
                    style: text.displayLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' ${context.loc.exams(recapData.examsCount).toLowerCase()}',
                    style: text.headlineMedium,
                  ),
                ],
              ),
            );
          },
        ),
        AnimatedItem(
          spacing: 32,
          builder: (isShown) {
            return RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: recapData.homeworksCount.toString(),
                    style: text.displayLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' ${context.loc.homework(recapData.homeworksCount).toLowerCase()}',
                    style: text.headlineMedium,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
