import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/features/subjects/presentation/subject_picker.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/group_models.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/task_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/screens/shared/nickname_text.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/priority_picker.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

class SharedAddBottomSheet extends ConsumerStatefulWidget {
  const SharedAddBottomSheet({
    super.key,
    required this.task,
    required this.isHomework,
    required this.subjects,
    required this.member,
  });

  final bool isHomework;
  final List<Subject> subjects;
  final Member member;
  final Task task;

  @override
  ConsumerState<SharedAddBottomSheet> createState() =>
      _SharedAddBottomSheetState();
}

class _SharedAddBottomSheetState extends ConsumerState<SharedAddBottomSheet> {
  late int priority = widget.task.priority.index;
  String? pickedSubjectId;
  bool couldntMatchSubject = false;

  late Map<String, GlobalKey> subjectChipsKeys = {
    for (final subject in widget.subjects) subject.id: GlobalKey(),
  };

  void onSave() async {
    Navigator.pop(context);
    if (widget.isHomework) {
      await ref
          .read(hwDataProvider.notifier)
          .update(
            widget.task.toHwData().copyWith(
              subjectId: pickedSubjectId,
              priority: priority,
            ),
          );
    } else {
      await ref
          .read(examDataProvider.notifier)
          .update(
            widget.task.toExamData().copyWith(
              subjectId: pickedSubjectId,
              priority: priority,
            ),
          );
    }
    if (mounted) {
      showMessage(context, 'Imported successfully');
    }
  }

  @override
  void initState() {
    super.initState();

    final subject = widget.task.subject;
    if (subject != null) {
      // try to match the subject with bakaId
      if (subject.bakaId != null) {
        pickedSubjectId = widget.subjects
            .where((element) => element.bakaId == subject.bakaId)
            .firstOrNull
            ?.id;
      } else {
        pickedSubjectId = widget.subjects
            .where(
              (element) => element.containsText(subject.name.split(' ')[0]),
            )
            .firstOrNull
            ?.id;
      }
      if (pickedSubjectId != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) => _subjectChipEnsureVisible(pickedSubjectId),
        );
      } else {
        couldntMatchSubject = true;
      }
    }
  }

  void _subjectChipEnsureVisible(String? subjectId) {
    if (subjectId != null) {
      final chipContext = subjectChipsKeys[subjectId]?.currentContext;
      if (chipContext != null) {
        Scrollable.ensureVisible(
          chipContext,
          duration: const Duration(milliseconds: 500),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.task.text,
            textAlign: TextAlign.start,
            style: context.txt.titleMedium,
          ),
          if (widget.task.description != '') Text(widget.task.description),
          SubjectPicker(
            chipKeys: subjectChipsKeys,
            subjects: widget.subjects,
            pickedSubjectId: pickedSubjectId,
            onSelected: (subject) {
              setState(() {
                pickedSubjectId = subject?.id;
              });
              _subjectChipEnsureVisible(pickedSubjectId);
            },
          ),
          if (couldntMatchSubject)
            ErrorTile(
              text: 'Couldn\'t match the subject: ${widget.task.subject?.name}',
              error: StringException('Please assing the subject manually'),
            ),
          PriorityPicker(
            selectedPriority: priority,
            onSelected: (value) => setState(() {
              priority = value;
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.loc.deadline,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  widget.task.date.formatFromSettings(context),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NicknameText(user: widget.member),
              FilledButton(
                onPressed: onSave,
                child: Text(context.loc.import),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
