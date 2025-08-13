import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/task_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/screens/shared/username_text.dart';
import 'package:schoolarc/services/firebase/firebase_sharing_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/subject_picker.dart';
import 'package:schoolarc/widgets/priority_picker.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

class SharedAddBottomSheet extends ConsumerStatefulWidget {
  const SharedAddBottomSheet({
    super.key,
    required this.task,
    required this.isHomework,
    required this.subjects,
    required this.owner,
  });

  final bool isHomework;
  final List<Subject> subjects;
  final MyUser owner;
  final Task task;

  @override
  ConsumerState<SharedAddBottomSheet> createState() =>
      _SharedAddBottomSheetState();
}

class _SharedAddBottomSheetState extends ConsumerState<SharedAddBottomSheet> {
  late int priority = widget.task.priority.index;
  String? pickedSubjectId;
  bool couldntMatchSubject = false;

  late List<GlobalKey> keys = List<GlobalKey>.generate(
    widget.subjects.length,
    (index) => GlobalKey(),
  );

  void onSave() async {
    Navigator.pop(context);
    if (widget.isHomework) {
      await ref.read(hwProvider.notifier).saveNew(
            widget.task.toHwEntity().copyWith(
                  subjectId: pickedSubjectId,
                  priority: priority,
                ),
            overrideId: widget.task.id,
          );
    } else {
      await ref.read(examProvider.notifier).saveNew(
            widget.task.toExamEntity().copyWith(
                  subjectId: pickedSubjectId,
                  priority: priority,
                ),
            overrideId: widget.task.id,
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
                (element) => element.containsText(subject.name.split(' ')[0]))
            .firstOrNull
            ?.id;
      }
      if (pickedSubjectId != null) {
        WidgetsBinding.instance
            .addPostFrameCallback((timeStamp) => ensureVisible());
      } else {
        couldntMatchSubject = true;
      }
    }
  }

  void ensureVisible() {
    if (pickedSubjectId == null) return;
    Scrollable.ensureVisible(
        keys[widget.subjects.indexWhere(
          (element) => element.id == pickedSubjectId,
        )]
            .currentContext!,
        duration: const Duration(milliseconds: 500));
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
          if (widget.task.description != null) Text(widget.task.description!),
          SubjectPicker(
            keys: keys,
            subjects: widget.subjects,
            pickedSubjectId: pickedSubjectId,
            onSelected: (subject) {
              setState(() {
                pickedSubjectId = subject?.id;
              });
              ensureVisible();
            },
          ),
          if (couldntMatchSubject)
            ErrorTile(
              contentPadding: const EdgeInsets.all(0),
              text: 'Couldn\'t match the subject: ${widget.task.subject?.name}',
              error: ServiceException('Please assing the subject manually'),
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
                  widget.task.deadline.formatWithoutYear(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UsernameText(user: widget.owner),
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
