import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/import_export.dart';
import 'package:schoolarc/widgets/dialogs/progress_dialog.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';

class ImportExportButtonsRow extends ConsumerWidget {
  const ImportExportButtonsRow({
    super.key,
    this.showExport = true,
    this.onDataSyncSuccess,
  });

  final bool showExport;
  final void Function()? onDataSyncSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: showExport ? .end : .center,
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showExport)
          M3EFilledButton.tonalIcon(
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () async {
              final json = export();

              final location = await FilePicker.saveFile(
                dialogTitle: context.loc.chooseSaveLocation,
                type: FileType.custom,
                allowedExtensions: ['json'],
                fileName:
                    'export_${DateTime.now().toIso8601String().replaceAll(RegExp(r':'), '-')}.json',
                bytes: utf8.encode(json),
              );

              if (context.mounted) {
                if (location == null) {
                  showMessage(context, context.loc.aborted);
                } else {
                  showMessage(context, context.loc.exportSuccess);
                  vibrate.success();
                }
              }
            },
            label: Text(context.loc.export),
          ),
        M3EFilledButton.tonalIcon(
          icon: const Icon(Icons.file_download_outlined),
          onPressed: () async {
            try {
              final pickedFile = await FilePicker.pickFiles(
                dialogTitle: context.loc.pickSaveFile,
                type: FileType.custom,
                allowedExtensions: ['json'],
              );

              if (pickedFile == null) {
                return;
              }

              File file = File(pickedFile.files.first.path!);
              Uint8List bytes;
              if (kIsWeb) {
                bytes = await pickedFile.files.first.readAsBytes();
              } else {
                bytes = await file.readAsBytes();
              }
              final imported = import(jsonString: utf8.decode(bytes));

              final subjectsCount = imported.subjects.length;
              final examsCount = imported.exams.length;
              final hwsCount = imported.hws.length;
              final totalCount = subjectsCount + examsCount + hwsCount;

              if (context.mounted) {
                showMyDialog(
                  context: context,
                  title: context.loc.import,
                  dismissible: false,
                  content: Text(
                    context.loc.importConfirmationText(
                      subjectsCount,
                      hwsCount,
                      examsCount,
                    ),
                  ),
                  actions: [
                    DialogActionButton(
                      text: context.loc.cancel,
                      onPressed: () => Navigator.pop(context),
                    ),
                    DialogActionButton(
                      text: context.loc.import,
                      isDefaultAction: true,
                      onPressed: () async {
                        final GlobalKey<ProgressDialogState> dialogKey =
                            GlobalKey();

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => ProgressDialog(
                            key: dialogKey,
                            goal: totalCount,
                            useHaptics: ref.read(
                              themeExpressiveHapticsProvider,
                            ),
                          ),
                        );
                        for (var element in imported.subjects) {
                          await ref
                              .read(subjectsProvider.notifier)
                              .create(
                                element.convert(),
                                overrideId: element.id,
                                syncWithFire: false,
                              );
                          dialogKey.currentState?.addProgress();
                        }
                        for (var element in imported.exams) {
                          await ref
                              .read(examDataProvider.notifier)
                              .update(element, syncWithFire: false);
                          dialogKey.currentState?.addProgress();
                        }
                        for (var element in imported.hws) {
                          await ref
                              .read(hwDataProvider.notifier)
                              .update(element, syncWithFire: false);
                          dialogKey.currentState?.addProgress();
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          showMessage(context, context.loc.importSuccess);
                          vibrate.success();
                        }
                        if (fireService.hasUser) {
                          syncAllTasks(ref);
                        }
                        if (onDataSyncSuccess != null) {
                          onDataSyncSuccess!();
                        }
                      },
                    ),
                  ],
                );
              }
            } catch (e) {
              if (context.mounted) {
                showErrorMessage(context, e);
                vibrate.error();
              }
            }
          },
          label: Text(context.loc.import),
        ),
      ],
    );
  }
}
