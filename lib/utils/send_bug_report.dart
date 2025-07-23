import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/globals.dart';
import 'package:url_launcher/url_launcher.dart';

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

Future<void> sendBugReport(BuildContext context, {String? bug}) async {
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

    final body = '$bug\n\n\n\n'
        'Schoolarc: ${packageInfo.version}+${packageInfo.buildNumber}\n'
        '$version \n'
        'RAM: $ram';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'mol.david498@gmail.com',
      query: encodeQueryParameters(
          <String, String>{'subject': 'Bug report', 'body': body}),
    );

    final value = await launchUrl(emailLaunchUri);
    if (!value && context.mounted) {
      showMessage(context, context.loc.cantOpenMail, isError: true);
    }
  } on Object catch (error) {
    if (context.mounted) {
      showMessage(context, error.toString(), isError: true);
    }
  }
}
