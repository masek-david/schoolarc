import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changelog'),
      ),
      body: FutureBuilder(
        future: rootBundle.loadString('changelog.md'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return MyExpressiveLoadingIndicator.big();
          }

          return Markdown(data: snapshot.data!);
        },
      ),
    );
  }
}
