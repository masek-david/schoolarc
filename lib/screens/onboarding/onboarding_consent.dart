import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class OnboardingConsent extends StatefulWidget {
  const OnboardingConsent({super.key, required this.next});

  final void Function() next;

  @override
  State<OnboardingConsent> createState() => _OnboardingConsentState();
}

class _OnboardingConsentState extends State<OnboardingConsent> {
  bool shareAgree = false;
  bool privacyPolicyAgree = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedPage(
        children: [
          AnimatedItem(
            builder: (isShown) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 64, 8, 16),
                child: Text(
                  context.loc.privacyPolicyTitle,
                  style: context.txt.headlineLarge,
                ),
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 32),
                child: GptMarkdown(context.loc.privacyPolicy),
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return SettingTile.withSwitch(
                isFirst: true,
                title: 'Agree send crash reports',
                subtitle:
                    'This is optional, however, it will help me fix bugs :)',
                value: shareAgree,
                onChanged: (value) {
                  settings.save(.shareErrorLogs, value);
                  setState(() {
                    shareAgree = value;
                  });
                },
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return SettingTile.withSwitch(
                isLast: true,
                title: 'Agree to privacy policy',
                value: privacyPolicyAgree,
                onChanged: (value) {
                  setState(() {
                    privacyPolicyAgree = value;
                  });
                },
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: FilledButton(
                  onPressed: privacyPolicyAgree ? widget.next : null,
                  child: Text(context.loc.continueAction),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
