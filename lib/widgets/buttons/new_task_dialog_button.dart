import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/widgets/dialogs/subject_picker.dart';
import 'package:schoolarc/widgets/priority_picker.dart';

class NewTaskDialogButton extends ConsumerStatefulWidget {
  const NewTaskDialogButton({super.key});

  @override
  ConsumerState<NewTaskDialogButton> createState() =>
      _NewTaskDialogButtonState();
}

class _NewTaskDialogButtonState extends ConsumerState<NewTaskDialogButton> {
  bool expanded = false;
  int priority = 0;
  String? pickedSubjectId;
  Date date = Date.today();
  late final subjects = ref.read(subjectsSortedProvider);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: () => setState(() {
          expanded = true;
        }),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 8,
          children: [
            if (expanded)
              FilledButton(
                onPressed: () => setState(() {
                  expanded = false;
                }),
                child: Text(context.loc.save),
              ),
            AnimatedContainer(
              curve: Curves.decelerate,
              duration: const Duration(milliseconds: 150),
              width: (expanded ? constraints.maxWidth - 32 : 56),
              height: (expanded ? constraints.maxHeight / 2 : 56),
              decoration: BoxDecoration(
                color: expanded
                    ? context.col.surfaceContainerLow
                    : context.col.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedCrossFade(
                firstChild: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 4,
                    children: [
                      SubjectPicker(
                        subjects: subjects,
                        pickedSubjectId: pickedSubjectId,
                        onSelected: (subject) => setState(() {
                          pickedSubjectId = subject?.id;
                        }),
                      ),
                      // todo translate
                      const TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText:
                              'Search for subjects, write the assignment...',
                        ),
                      ),
                      // PriorityPickerExpressive(
                      //   selectedPriority: priority,
                      //   onSelected: (value) => setState(() {
                      //     priority = value;
                      //   }),
                      // ),
                      PriorityPicker(
                        selectedPriority: priority,
                        onSelected: (value) => setState(() {
                          priority = value;
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.loc.deadline,
                              style: context.txt.titleMedium,
                            ),
                            Text(date.formatFromSettings(context))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                secondChild: Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: context.col.onPrimaryContainer,
                  ),
                ),
                crossFadeState: expanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 150),
                sizeCurve: Curves.decelerate,
                firstCurve: Curves.decelerate,
                secondCurve: Curves.decelerate,
              ),
            ),
          ],
        ),
      );
    });
  }
}
