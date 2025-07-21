import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

Future<bool?> showConsentDialog(BuildContext context, WidgetRef ref) {
  return showDialog<bool>(
    context: context,
    builder: (context) => Dialog.fullscreen(
      child: Column(
        children: [
          AppBar(),
          Expanded(child: Markdown(data: context.loc.privacyPolicy)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                    ref.read(useCloudSyncProvider.notifier).setConsent(false);
                  },
                  child: Text(context.loc.disagree),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    ref.read(useCloudSyncProvider.notifier).setConsent(true);
                  },
                  child: Text(context.loc.agree),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

final useCloudSyncProvider =
    NotifierProvider<UseCloudSyncNotifier, bool>(UseCloudSyncNotifier.new);

class UseCloudSyncNotifier extends Notifier<bool> {
  @override
  bool build() {
    return settings.get(Setting.useFirebase) &&
        settings.get(Setting.cloudSyncConsent) == true;
  }

  Future<void> set(bool value, BuildContext context, WidgetRef ref) async {
    if (settings.get(Setting.cloudSyncConsent) == true || value == false) {
      settings.save(Setting.useFirebase, value);
      state = value;
      return;
    }

    if (await showConsentDialog(context, ref) == true) {
      settings.save(Setting.useFirebase, value);
      state = value;
    }
  }

  void setConsent(bool value) {
    settings.save(Setting.cloudSyncConsent, value);
    if (value == false) {
      settings.save(Setting.useFirebase, false);
      state = false;
    }
  }
}
