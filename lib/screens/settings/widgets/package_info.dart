import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class PackageInfoWidget extends ConsumerWidget {
  const PackageInfoWidget({
    super.key,
    this.enableTap = false,
  });

  final bool enableTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int tapped = 0;
    return GestureDetector(
      onTap: enableTap
          ? () {
              tapped++;
              if (ref.read(devModeProvider)) {
                showMessage(context, context.loc.alreadyDeveloper);
                return;
              }
              if (tapped == 3) {
                showMessage(
                    context, context.loc.pressMoreTimesToBecomeDeveloper);
              }
              if (tapped == 5) {
                showMessage(context, context.loc.becameDeveloper);
                tapped = 0;
                ref.read(devModeProvider.notifier).set(true);
              }
            }
          : null,
      child: Text(
        '${packageInfo.version} build ${packageInfo.buildNumber}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}
