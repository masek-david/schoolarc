import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/utils/import_export.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';

class ImportExportRow extends ConsumerWidget {
  const ImportExportRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: () async {
              final json = export();
      
              await FilePicker.platform.saveFile(
                  dialogTitle: 'Choose location for save file:',
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                  fileName:
                      'school_app_export_${DateTime.now().toIso8601String()}.json',
                  bytes: utf8.encode(json));
            },
            child: Text('Export app data'),
          ),
          OutlinedButton(
            // TODO handle errors
            // TODO 2.0.0 make this functional
            // ignore: dead_code
            onPressed: true ? null : () async {
              final pickedFile = await FilePicker.platform.pickFiles(
                dialogTitle: 'Pick a save file:',
                type: FileType.custom,
                allowedExtensions: ['json'],
              );
      
              if (pickedFile == null) {
                return;
              }
      
              File file = File(pickedFile.files.first.path!);
              final bytes = await file.readAsBytes();
              final imported = import(jsonString: utf8.decode(bytes));
      
              final subjects = (imported['subjects'] as List<Subject>);
              final exams = (imported['exams'] as List<Exam>);
              final homeworks = (imported['homework'] as List<Homework>);
      
              final subjectsCount = subjects.length;
              final examsCount = exams.length;
              final hwsCount = homeworks.length;
      
              if (context.mounted) {
                showDialogAdaptive(
                    context: context,
                    title: Text('Import'),
                    content: Text(
                      'Do you want to import $subjectsCount subject${subjectsCount == 1 ? '' : 's'}, $hwsCount piece${hwsCount == 1 ? '' : 's'} of homework and $examsCount exam${examsCount == 1 ? '' : 's'}?',
                    ),
                    actions: [
                      adaptiveDialogButton(
                        context: context,
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      adaptiveDialogButton(
                        context: context,
                        child: Text('Import'),
                        onPressed: () async {
                          for (var element in subjects) {
                            await ref
                                .read(subjectsProvider.notifier)
                                .saveNew(element);
                          }
                          for (var element in exams) {
                            await ref
                                .read(examProvider.notifier)
                                .saveNew(element);
                          }
                          for (var element in homeworks) {
                            await ref.read(hwProvider.notifier).saveNew(element);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ]);
              }
            },
            child: Text('Import app data'),
          ),
        ],
      ),
    );
  }
}
