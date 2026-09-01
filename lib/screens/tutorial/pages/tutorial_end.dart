import 'package:flutter/material.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
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
        M3EFilledButton.icon(
          size: .lg,
          onPressed: () {
            Posthog().capture(eventName: 'Tutorial Completed');
            Navigator.pop(context);
          },
          icon: const Icon(Icons.exit_to_app_rounded),
          label: Text(context.loc.exit),
        ),
      ],
    );
  }
}
