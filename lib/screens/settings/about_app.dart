import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schoolarc/screens/onboarding/privacy_policy.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/package_info.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/utils/color_mapper.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/send_bug_report.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      heroTag: 'about',
      title: context.loc.aboutApp,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SvgPicture.asset(
            'assets/schoolarc_logo.svg',
            height: 100,
            colorMapper: LogoColorMapper(
              isDark: Theme.of(context).brightness == Brightness.dark,
              primaryFixedDimColor: context.col.primaryFixedDim.toARGB32(),
              secondaryColor: context.col.secondary.toARGB32(),
              useThemeColors: false,
            ),
          ),
        ),
        const Center(
          child: PackageInfoWidget(),
        ),
        const SizedBox(height: 16),
        SettingTile(
          isFirst: true,
          title: context.loc.viewAppChangelog,
          leading: const Icon(Icons.history_outlined),
          onTap: (context) =>
              Navigator.restorablePushNamed(context, '/changelog'),
        ),
        SettingTile(
          title: context.loc.reportBug,
          subtitle: context.loc.reportBugPolicy,
          leading: const Icon(Icons.bug_report_outlined),
          onTap: sendBugReport,
        ),
        SettingTile(
          title: context.loc.viewLogs,
          leading: const Icon(Icons.data_array),
          onTap: (context) => Navigator.restorablePushNamed(context, '/logs'),
        ),
        SettingTile(
          title: context.loc.privacyPolicyTitle,
          leading: const Icon(Icons.privacy_tip_rounded),
          onTap: (context) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PrivacyPolicy(),
            ),
          ),
        ),
        SettingTile(
          isLast: true,
          title: context.loc.viewLicenses,
          leading: const Icon(Icons.attribution),
          onTap: (context) => showLicensePage(
            context: context,
            applicationIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/schoolarc_icon.svg',
                height: 80,
                colorMapper: LogoColorMapper(
                  isDark: Theme.of(context).brightness == Brightness.dark,
                  primaryFixedDimColor: context.col.primaryFixedDim.toARGB32(),
                  secondaryColor: context.col.secondary.toARGB32(),
                  useThemeColors: false,
                ),
              ),
            ),
            applicationVersion: packageInfo.version,
          ),
        ),
        SettingTile(
          isFirst: true,
          isLast: true,
          title: context.loc.viewSourceCode,
          leading: const Icon(Icons.code_rounded),
          // TODO link github
          onTap: (context) {},
          trailing: const Icon(Icons.link_rounded),
        ),
      ],
    );
  }
}
