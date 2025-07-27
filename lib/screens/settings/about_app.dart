import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.aboutApp),
      ),
      body: ListView(
        children: [
          SvgPicture.asset(
            'assets/schoolarc_logo.svg',
            height: 100,
            colorMapper: LogoColorMapper(
              isDark: Theme.of(context).brightness == Brightness.dark,
              primaryFixedDimColor: context.col.primaryFixedDim.toARGB32(),
              secondaryColor: context.col.secondary.toARGB32(),
              useThemeColors: false,
            ),
          ),
          const Center(
            child: PackageInfoWidget(),
          ),
          SettingTile(
            title: context.loc.viewAppChangelog,
            leading: const Icon(Icons.history_outlined),
            onTap: (context) =>
                Navigator.restorablePushNamed(context, '/changelog'),
          ),
          SettingTile(
              title: context.loc.reportBug,
              subtitle: context.loc.reportBugPolicy,
              leading: const Icon(Icons.bug_report_outlined),
              onTap: sendBugReport),
          SettingTile(
            title: context.loc.viewLogs,
            leading: const Icon(Icons.data_array),
            onTap: (context) =>
                Navigator.restorablePushNamed(context, '/logs'),
          ),
          SettingTile(
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
                    primaryFixedDimColor:
                        context.col.primaryFixedDim.toARGB32(),
                    secondaryColor: context.col.secondary.toARGB32(),
                    useThemeColors: false,
                  ),
                ),
              ),
              applicationVersion: packageInfo.version,
            ),
          ),
        ],
      ),
    );
  }
}
