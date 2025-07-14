import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/import_export.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';
import 'package:school_manager/widgets/progress_dialog.dart';

class ImportExportRow extends ConsumerWidget {
  const ImportExportRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.loc.appDataLabel,
            style: const TextStyle(fontSize: 16),
          ),
          Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.tonalIcon(
                label: Text(context.loc.export),
                icon: const Icon(Icons.file_upload_outlined),
                onPressed: () async {
                  final json = export();

                  await FilePicker.platform.saveFile(
                    dialogTitle: context.loc.chooseSaveLocation,
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                    fileName:
                        'export_${DateTime.now().toIso8601String().replaceAll(RegExp(r':'), '-')}.json',
                    bytes: utf8.encode(json),
                  );
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
                    final bytes = await file.readAsBytes();
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
                                subjectsCount, hwsCount, examsCount),
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
                                  builder: (context) => ProgressDialog(
                                    key: dialogKey,
                                    goal: totalCount,
                                  ),
                                );
                                for (var element in imported.subjects) {
                                  await ref
                                      .read(subjectsProvider.notifier)
                                      .saveNew(
                                        element.convert(),
                                        overrideId: element.id,
                                        addToFire: false,
                                      );
                                  dialogKey.currentState?.addProgress();
                                }
                                for (var element in imported.exams) {
                                  await ref.read(examProvider.notifier).saveNew(
                                        element,
                                        overrideId: element.id,
                                        addToFire: false,
                                      );
                                  dialogKey.currentState?.addProgress();
                                }
                                for (var element in imported.hws) {
                                  await ref.read(hwProvider.notifier).saveNew(
                                        element,
                                        overrideId: element.id,
                                        addToFire: false,
                                      );
                                  dialogKey.currentState?.addProgress();
                                }
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                                if (settings.get(Setting.useFirebase)) {
                                  syncAllTasks(ref);
                                }
                              },
                            ),
                          ]);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showMessage(context, e.toString(), isError: true);
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
