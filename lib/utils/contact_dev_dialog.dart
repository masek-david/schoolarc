import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/button_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

void contactDev(BuildContext context) {
  showButtonDialog(
    context,
    icon: Icons.send_rounded,
    title: context.loc.contact,
    buttons: [
      ButtonDialogButton(
        isFirst: true,
        text: context.loc.iHaveAnIssue,
        onTap: () {
          Navigator.pop(context);
          _reportBug(context);
        },
      ),
      ButtonDialogButton(
        isLast: true,
        text: context.loc.iHaveAnIdea,
        onTap: () {
          Navigator.pop(context);
          _requestFeature(context);
        },
      ),
    ],
  );
}

void _reportBug(BuildContext context) {
  showButtonDialog(
    context,
    icon: Icons.bug_report_rounded,
    title: context.loc.iHaveAnIssue,
    buttons: [
      ButtonDialogButton(
        isFirst: true,
        text: context.loc.sendEmail,
        onTap: () {
          Navigator.pop(context);
          emailBugReport(context);
        },
      ),
      ButtonDialogButton(
        isLast: true,
        text: context.loc.createGithubIssue,
        onTap: () {
          Navigator.pop(context);
          launchUrl(Uri.parse('$githubUrl/issues/new?labels=bug'));
        },
      ),
    ],
  );
}

void _requestFeature(BuildContext context) {
  showButtonDialog(
    context,
    icon: Icons.lightbulb_rounded,
    title: context.loc.iHaveAnIdea,
    buttons: [
      ButtonDialogButton(
        isFirst: true,
        text: context.loc.sendEmail,
        onTap: () {
          Navigator.pop(context);
          emailFeatureRequest(context);
        },
      ),
      ButtonDialogButton(
        isLast: true,
        text: context.loc.createGithubIssue,
        onTap: () {
          Navigator.pop(context);
          launchUrl(Uri.parse('$githubUrl/issues/new?labels=enhancement'));
        },
      ),
    ],
  );
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map(
        (MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
      )
      .join('&');
}

Future<void> emailFeatureRequest(BuildContext context) async {
  try {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'dev@masci.cz',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Schoolarc feature request',
      }),
    );

    final value = await launchUrl(emailLaunchUri);
    if (!value && context.mounted) {
      showErrorMessage(context, StringException(context.loc.cantOpenMail));
    }
  } catch (e) {
    if (context.mounted) {
      showErrorMessage(context, e);
    }
  }
}

Future<void> emailBugReport(BuildContext context, {String? bug}) async {
  try {
    bug ??= context.loc.bugReportHint;
    final deviceInfo = DeviceInfoPlugin();

    String version = '';
    String ram = 'unknown';

    if (kIsWeb) {
      final web = await deviceInfo.webBrowserInfo;
      version = 'Web ${web.browserName} ${web.platform}';
      ram = '${(web.deviceMemory ?? 0) / 1024} MB';
    } else if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      version =
          'Android ${android.version.release} (SDK ${android.version.sdkInt})';
      ram = '${android.physicalRamSize} MB';
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      version = '${ios.systemName} ${ios.systemVersion}';
      ram = '${ios.physicalRamSize} MB';
    } else if (Platform.isWindows) {
      final windows = await deviceInfo.windowsInfo;
      version =
          'Windows ${windows.displayVersion} (Build ${windows.buildNumber})';
      ram = '${windows.systemMemoryInMegabytes} MB';
    } else if (Platform.isMacOS) {
      final mac = await deviceInfo.macOsInfo;
      version = '${mac.osRelease} ${mac.kernelVersion}';
      ram = '${mac.memorySize} MB';
    } else if (Platform.isLinux) {
      final linux = await deviceInfo.linuxInfo;
      version = linux.prettyName;
    }

    final body =
        '$bug\n\n\n\n'
        'Schoolarc: $appVersion+$appBuildNumber\n'
        '$version \n'
        'RAM: $ram';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'dev@masci.cz',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Schoolarc bug report',
        'body': body,
      }),
    );

    final value = await launchUrl(emailLaunchUri);
    if (!value && context.mounted) {
      showErrorMessage(context, StringException(context.loc.cantOpenMail));
    }
  } catch (e) {
    if (context.mounted) {
      showErrorMessage(context, e);
    }
  }
}
