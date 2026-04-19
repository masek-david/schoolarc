import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/utils/globals.dart';

class AppInfo {
  AppInfo({
    required this.requiredBuild,
    required this.currentBuild,
    required this.message,
    required this.messageForOldVersion,
  });

  final int requiredBuild;
  final int currentBuild;
  final String? message;
  final String? messageForOldVersion;

  @override
  String toString() {
    return 'Current build: $currentBuild, Required build: $requiredBuild; $message, $messageForOldVersion';
  }
}

final appInfoProvider = AsyncNotifierProvider<AppInfoNotifier, AppInfo>(
  AppInfoNotifier.new,
);

class AppInfoNotifier extends AsyncNotifier<AppInfo> {
  @override
  Future<AppInfo> build() async {
    final data = await fireService.getAppInfo();

    final requiredBuild = data.child('requiredBuild').value as int;

    return AppInfo(
      requiredBuild: requiredBuild,
      currentBuild: data.child('currentBuild').value as int,
      message: data.child('message').value as String?,
      messageForOldVersion: data.child('messageForOldVersion').value as String?,
    );
  }
}

final needsUpdateProvider = NotifierProvider<NeedsUpdateNotifier, bool>(
  NeedsUpdateNotifier.new,
);

class NeedsUpdateNotifier extends Notifier<bool> {
  @override
  bool build() {
    ref.listen(
      appInfoProvider,
      (previous, next) {
        if (next.value != null) {
          settings.save(.requiredBuild, next.value!.requiredBuild);
          state = _needsUpdate();
        }
      },
    );

    return _needsUpdate();
  }

  bool _needsUpdate() {
    final requiredBuild = settings.get(.requiredBuild);
    if (requiredBuild == null) return false;

    return appBuildNumber < requiredBuild;
  }

  void bypass(){
    state = false;
  }
}
