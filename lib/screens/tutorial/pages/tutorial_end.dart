import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/button_m3e.dart';
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
        ButtonM3E.filled(
          size: .large,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.exit_to_app_rounded),
          child: Text(context.loc.exit),
        ),
      ],
    );
  }
}
