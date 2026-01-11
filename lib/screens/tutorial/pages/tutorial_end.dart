import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class TutorialEnd extends StatelessWidget {
  const TutorialEnd({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      spacing: 32,
      children: [
        Text(context.loc.tutorialCompleted, style: context.txt.headlineMedium),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(context.loc.exit),
        ),
      ],
    );
  }
}
