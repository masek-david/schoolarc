import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: context.loc.privacyPolicyTitle,
      heroTag: 'privacyPolicy',
      children: const [],
      child: Markdown(
        data: context.loc.privacyPolicy,
        padding: const EdgeInsets.only(bottom: 36),
      ),
    );
  }
}
