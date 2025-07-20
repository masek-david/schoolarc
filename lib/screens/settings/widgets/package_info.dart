import 'package:flutter/material.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

class PackageInfoWidget extends StatelessWidget {
  const PackageInfoWidget({
    super.key,
    this.onBecameDev,
  });

  final void Function()? onBecameDev;

  @override
  Widget build(BuildContext context) {
    int tapped = 0;
    return InkWell(
      onTap: onBecameDev == null ? null : () {
        tapped++;
        if (settings.get(Setting.showDebugInfo)) {
          showMessage(context, context.loc.alreadyDeveloper);
          return;
        }
        if (tapped == 3) {
          showMessage(context, context.loc.pressMoreTimesToBecomeDeveloper);
        }
        if (tapped == 5) {
          showMessage(context, context.loc.becameDeveloper);
          tapped = 0;
          onBecameDev!();
        }
      },
      child: Text(
        '${packageInfo.version} build ${packageInfo.buildNumber}',
        style: TextStyle(
            color: Theme.of(context).colorScheme.surfaceContainerHighest),
      ),
    );
  }
}
