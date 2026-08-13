import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
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
  bool shareLogs = settings.get(.shareErrorLogs);
  bool privacyPolicyAgree = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedPage(
        vibrate: true,
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
                padding: const EdgeInsetsGeometry.only(bottom: 16),
                child: Markdown(
                  padding: const EdgeInsets.all(0),
                  data: context.loc.privacyPolicy,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                ),
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return SettingTile.withSwitch(
                isFirst: true,
                title: context.loc.agreeSendCrashReports,
                subtitle: context.loc.agreeSendCrashReportsSubtitle,
                value: shareLogs,
                onChanged: (value) {
                  settings.save(.shareErrorLogs, value);
                  setState(() {
                    shareLogs = value;
                  });
                },
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return SettingTile.withSwitch(
                isLast: true,
                title: context.loc.agreeToPrivacyPolicy,
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
                child: M3EFilledButton.icon(
                  size: .md,
                  onPressed: privacyPolicyAgree ? widget.next : null,
                  icon: const Icon(Icons.keyboard_arrow_right_rounded),
                  label: Text(context.loc.continueAction),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
