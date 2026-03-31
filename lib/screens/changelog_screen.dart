import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';

class ChangelogScreen extends ConsumerWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changelog'),
      ),
      body: FutureBuilder(
        future: rootBundle.loadString('assets/changelog.md'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return ExpressiveLoadingIndicator.big(
              useHaptics: ref.read(themeExpressiveHapticsProvider),
            );
          }

          return GptMarkdown(snapshot.data!);
        },
      ),
    );
  }
}
