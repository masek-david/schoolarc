
import 'package:flutter/material.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

class PackageInfoWidget extends StatelessWidget {
  const PackageInfoWidget({
    super.key,
    required this.onBecameDev,
  });

  final void Function() onBecameDev;

  @override
  Widget build(BuildContext context) {
    int tapped = 0;
    return InkWell(
      onTap: () {
        tapped++;
        if (settings.get(Setting.showDebugInfo)) {
          showMessage(context, 'You are already the developer');
          return;
        }
        if (tapped == 3) {
          showMessage(context, 'Press 2 more times to become developer');
        }
        if (tapped == 5) {
          showMessage(context, 'You\'ve become the developer');
          tapped = 0;
          onBecameDev();
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
