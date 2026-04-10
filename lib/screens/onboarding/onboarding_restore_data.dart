import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/screens/firebase/cloudsync_login_screen.dart';
import 'package:schoolarc/screens/settings/widgets/import_export_row.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';

class OnboardingRestoredata extends ConsumerWidget {
  const OnboardingRestoredata({super.key, required this.next});

  final void Function() next;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(hwProvider).isNotEmpty ||
        ref.watch(examProvider).isNotEmpty) {
      return SafeArea(
        child: AnimatedPage(
          children: [
            AnimatedItem(
              builder: (isShown) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 64, 8, 16),
                  child: Text(
                    context.loc.dataLoaded,
                    style: context.txt.headlineMedium,
                  ),
                );
              },
            ),
            AnimatedItem(
              builder: (isShown) {
                return SettingTile(
                  isLast: true,
                  isFirst: true,
                  title: context.loc.continueAction,
                  onTap: (context) => next(),
                );
              },
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: AnimatedPage(
        children: [
          AnimatedItem(
            builder: (isShown) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 64, 8, 16),
                child: Text(
                  context.loc.restoreDataChoiceTitle,
                  style: context.txt.headlineMedium,
                ),
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return SettingTile(
                heroTag: 'cloudsync',
                isFirst: true,
                title: context.loc.cloudSync,
                subtitle: context.loc.cloudSyncSubtitle,
                leading: ref.watch(firebaseLoginProvider).value == null
                    ? null
                    : const Icon(Icons.check_circle, color: Colors.green),
                onTap: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CloudSyncLoginScreen(
                        onDataSyncSuccess: next,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return SettingTile(
                isLast: true,
                title: context.loc.importBackupFile,
                subtitle: context.loc.importBackupFileSub,
                newLineAction: ImportExportButtonsRow(
                  showExport: false,
                  onDataSyncSuccess: next,
                ),
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return Center(
                child: GestureDetector(
                  onTap: () {
                    showMyDialog(
                      context: context,
                      title: context.loc.skipRestoringQ,
                      content: Text(context.loc.skipRestoringSub),
                      actions: [
                        DialogActionButton(
                          text: context.loc.cancel,
                          onPressed: () => Navigator.pop(context),
                        ),
                        DialogActionButton(
                          text: context.loc.skipRestoring,
                          isDestructiveAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                            next();
                          },
                        ),
                      ],
                    );
                  },
                  child: Text(
                    context.loc.skipRestoring,
                    style: TextStyle(
                      color: context.col.surfaceContainerHighest,
                      fontSize: 14,
                      fontWeight: .w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
