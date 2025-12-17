import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/provider/use_cloudsync_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/import_export.dart';
import 'package:schoolarc/widgets/dialogs/progress_dialog.dart';
import 'package:schoolarc/widgets/dialogs/show_adaptive_dialog.dart';

class ImportExportButtonsRow extends ConsumerWidget {
  const ImportExportButtonsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 8,
      mainAxisSize: MainAxisSize.max,
      children: [
        FilledButton.tonalIcon(
          label: Text(context.loc.export),
          icon: const Icon(Icons.file_upload_outlined),
          onPressed: () async {
            final json = export();

            final location = await FilePicker.platform.saveFile(
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
              }
            }
          },
        ),
        FilledButton.tonalIcon(
          label: Text(context.loc.import),
          icon: const Icon(Icons.file_download_outlined),
          onPressed: () async {
            try {
              final pickedFile = await FilePicker.platform.pickFiles(
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
                bytes = pickedFile.files.first.bytes!;
              } else {
                bytes = await file.readAsBytes();
              }
              final imported = import(jsonString: utf8.decode(bytes));

              final subjectsCount = imported.subjects.length;
              final examsCount = imported.exams.length;
              final hwsCount = imported.hws.length;
              final totalCount = subjectsCount + examsCount + hwsCount;

              if (context.mounted) {
                showDialogAdaptive(
                  context: context,
                  title: Text(context.loc.import),
                  dismissible: false,
                  content: Text(
                    context.loc.importConfirmationText(
                      subjectsCount,
                      hwsCount,
                      examsCount,
                    ),
                  ),
                  actions: [
                    adaptiveDialogButton(
                      context: context,
                      child: Text(context.loc.cancel),
                      onPressed: () => Navigator.pop(context),
                    ),
                    adaptiveDialogButton(
                      context: context,
                      isDefaultAction: true,
                      child: Text(context.loc.import),
                      onPressed: () async {
                        final GlobalKey<ProgressDialogState> dialogKey =
                            GlobalKey();

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              ProgressDialog(key: dialogKey, goal: totalCount),
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
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                        if (ref.watch(useCloudSyncProvider)) {
                          syncAllTasks(ref);
                        }
                      },
                    ),
                  ],
                );
              }
            } catch (e) {
              if (context.mounted) {
                showMessage(context, e.toString(), isError: true);
              }
            }
          },
        ),
      ],
    );
  }
}
