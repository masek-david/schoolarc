import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: context.loc.privacyPolicyTitle,
      heroTag: 'privacyPolicy',
      children: const [],
      child: Markdown(
        onTapLink: (text, href, title) {
          if (href != null) launchUrl(Uri.parse(href));
        },
        data: context.loc.privacyPolicy,
        padding: const EdgeInsets.only(bottom: 36),
      ),
    );
  }
}
