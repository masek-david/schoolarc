import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/dialogs/show_adaptive_dialog.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/widgets/expressive_loading/linear_wavy_progress_indicator.dart';

class MyBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    dynamic element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final url = element.attributes['href'] ?? '';

    return GestureDetector(
      onTap: () {
        showDialogAdaptive(
          context: context,
          content: Text(url.replaceAll(';', '\n')),
          title: Text(element.textContent),
          actions: [
            adaptiveDialogButton(
              context: context,
              child: Text(context.loc.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
      child: Text(
        element.textContent,
        style: context.txt.displaySmall!.copyWith(
          color: context.col.primary,
        ),
      ),
    );
  }
}

class CustomDividerBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    dynamic element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: LinearWavyProgressIndicator(
        activeColor: context.col.surfaceContainerHighest,
        duration: const Duration(milliseconds: 2000),
        forceFullWave: true,
        value: 1,
        strokeWidth: 4,
      ),
    );
  }
}

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

          return Markdown(
            data: snapshot.data!,
            builders: {
              'hr': CustomDividerBuilder(),
              'a': MyBuilder(),
            },
          );
        },
      ),
    );
  }
}
