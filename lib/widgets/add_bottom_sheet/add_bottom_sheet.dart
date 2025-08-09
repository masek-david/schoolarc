import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/task_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/screens/timetable/select_subject.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/intent/intents.dart';
import 'package:schoolarc/widgets/cancel_save_button.dart';
import 'package:schoolarc/widgets/keyboard_date_picker/keyboard_date_picker.dart';
import 'package:schoolarc/widgets/priority_picker.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({
    super.key,
    required this.initialTaskId,
    required this.isHomework,
    required this.initialDate,
    required this.autoSetDate,
  });

  /// if [initialTaskId] is null, a empty task is created
  final String? initialTaskId;
  final DateTime? initialDate;

  /// if true, when a subject is selected, the date will be set to first appearance of this subject in constant timetable
  final bool autoSetDate;
  final bool isHomework;

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet>
    with RestorationMixin {
  late final initialTask = (widget.isHomework
          ? ref.read(hwProvider)[widget.initialTaskId]
          : ref.read(examProvider)[widget.initialTaskId]) ??
      Task.empty().copyWith(deadline: widget.initialDate);
  late final nameController = RestorableTextEditingController.fromValue(
    TextEditingValue(text: initialTask.text),
  );
  late final descriptionController = RestorableTextEditingController.fromValue(
    TextEditingValue(text: initialTask.description ?? ''),
  );
  late RestorableStringN pickedSubjectId =
      RestorableStringN(initialTask.subject?.id);
  late RestorableDateTime pickedDate = RestorableDateTime(initialTask.deadline);
  late RestorableInt pickedPriority = RestorableInt(initialTask.priority.index);

  late List<Subject> subjects = ref.read(subjectsSortedProvider);
  final _timetable = timetableDb.timeTable;

  late List<GlobalKey> keysList = List<GlobalKey>.generate(
    subjects.length,
    (index) => GlobalKey(),
  );

  void onSave() {
    final task = initialTask.copyWith(
      subject: ref.read(subjectsProvider)[pickedSubjectId.value],
      text: nameController.value.text,
      description: descriptionController.value.text,
      deadline: pickedDate.value,
      priority: TaskPriority(pickedPriority.value),
      timestamp: DateTime.now().toUtc(),
    );

    if (widget.isHomework) {
      if (task.id == '') {
        ref.read(hwProvider.notifier).saveNew(task.toHwEntity());
      } else {
        ref.read(hwProvider.notifier).edit(task as Homework);
      }
    } else {
      if (task.id == '') {
        ref.read(examProvider.notifier).saveNew(task.toExamEntity());
      } else {
        ref.read(examProvider.notifier).edit(task as Exam);
      }
    }
  }

  void setSubject(Subject? subject) {
    setState(() {
      pickedSubjectId.value = subject?.id;
      if (widget.autoSetDate && subject != null) {
        pickedDate.value =
            _timetable.nextDateForSubject(subject) ?? pickedDate.value;
      }
    });
    if (subject != null) {
      Scrollable.ensureVisible(
          keysList[subjects.indexOf(subject)].currentContext!,
          duration: const Duration(milliseconds: 500));
    }
  }

  void pickDate({bool keyboard = false}) async {
    DateTime? newDate;
    if (keyboard) {
      newDate = await showDialog<DateTime?>(
        context: context,
        builder: (context) => KeyboardDatePicker(initialDate: pickedDate.value),
      );
    } else {
      newDate = await showDatePicker(
        context: context,
        locale: Locale(
          Localizations.localeOf(context).languageCode,
          ref.watch(weekStartsOnMondayProvider) ? 'GB' : 'US',
        ),
        initialDate: pickedDate.value,
        firstDate: DateTime.utc(0),
        lastDate: DateTime.utc(3000),
      );
    }

    if (newDate == null) return;

    setState(() {
      pickedDate.value = newDate!;
    });
    return;
  }

  void pickSubject() async {
    final newSubject = await showDialog(
      context: context,
      builder: (context) => SelectSubjectDialog(
        subjects: subjects,
        showAllSubjects: false,
      ),
    );

    setSubject(newSubject);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pickedSubjectId.value != null) {
        Scrollable.ensureVisible(
          keysList[subjects.indexWhere(
            (element) => pickedSubjectId.value == element.id,
          )]
              .currentContext!,
          duration: const Duration(milliseconds: 500),
        );
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    pickedDate.dispose();
    pickedSubjectId.dispose();
    pickedPriority.dispose();

    super.dispose();
  }

  @override
  String? get restorationId => 'addBottomSheet';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(nameController, 'nameController');
    registerForRestoration(descriptionController, 'descriptionController');
    registerForRestoration(pickedDate, 'pickedDate');
    registerForRestoration(pickedSubjectId, 'pickedSubject');
    registerForRestoration(pickedPriority, 'pickedPriority');
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1):
            const PickPriorityIntent(0),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2):
            const PickPriorityIntent(1),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3):
            const PickPriorityIntent(2),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit4):
            const PickPriorityIntent(3),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.numpad1):
            const PickPriorityIntent(0),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.numpad2):
            const PickPriorityIntent(1),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.numpad3):
            const PickPriorityIntent(2),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.numpad4):
            const PickPriorityIntent(3),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyD):
            const PickDateIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
            const PickSubjectIntent(),
      },
      child: Actions(
        actions: {
          PickPriorityIntent: CallbackAction(
            onInvoke: (intent) => setState(() {
              pickedPriority.value = (intent as PickPriorityIntent).priority;
            }),
          ),
          PickDateIntent: CallbackAction(
            onInvoke: (intent) => pickDate(keyboard: true),
          ),
          PickSubjectIntent: CallbackAction(
            onInvoke: (intent) => pickSubject(),
          ),
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  CancelSaveButton(onSave: onSave),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      IconButton(
                        onPressed: pickSubject,
                        icon: const Icon(Icons.search),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            // cant use .map(), i need the index
                            children: List.generate(subjects.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  key: keysList[index],
                                  selected: pickedSubjectId.value ==
                                      subjects[index].id,
                                  label: Text(subjects[index].name),
                                  onSelected: (value) {
                                    if (!value) {
                                      setSubject(null);
                                    } else {
                                      setSubject(subjects[index]);
                                    }
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Autocomplete<Subject>(
                    fieldViewBuilder: (context, textEditingController,
                        focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: nameController.value,
                        focusNode: focusNode,
                        autofocus: true,
                        maxLines: null,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          if (nameController.value.text.isNotEmpty) {
                            onSave();
                          }
                        },
                        onChanged: (value) {
                          textEditingController.text = value;
                        },
                        onEditingComplete: () {},
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(15),
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                    onSelected: (subject) {
                      nameController.value.text = '';
                      setSubject(subject);
                    },
                    displayStringForOption: (subject) {
                      return subject.name;
                    },
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text == '' ||
                          pickedSubjectId.value != null) {
                        return const Iterable.empty();
                      }
                      return subjects.where(
                        (subject) {
                          return subject.containsText(textEditingValue.text);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    // listview musi mit vysku, kterou urci sizedbox
                    height: 40,
                    child: PriorityPicker(
                      selectedPriority: pickedPriority.value,
                      onSelected: (value) => setState(() {
                        pickedPriority.value = value;
                      }),
                    ),
                  ),
                  const Divider(),
                  InkWell(
                    onTap: pickDate,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 15, bottom: 15, left: 5, right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.loc.deadline,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            pickedDate.value.formatWithoutYear(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text(context.loc.today),
                        selected: pickedDate.value.isSameDay(DateTime.now()),
                        onSelected: (value) {
                          DateTime now = DateTime.now();
                          setState(() {
                            pickedDate.value =
                                DateTime(now.year, now.month, now.day);
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(context.loc.tomorrow),
                        selected: pickedDate.value.isSameDay(
                            DateTime.now().add(const Duration(days: 1))),
                        onSelected: (value) {
                          DateTime now = DateTime.now();
                          setState(() {
                            pickedDate.value =
                                DateTime(now.year, now.month, now.day)
                                    .add(const Duration(days: 1));
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(
                            '${context.loc.next} ${DateFormat.EEEE(getLocale().languageCode).format(DateTime.now()).toLowerCase()}'),
                        selected: pickedDate.value.isSameDay(
                            DateTime.now().add(const Duration(days: 7))),
                        onSelected: (value) {
                          DateTime now = DateTime.now();
                          setState(() {
                            pickedDate.value =
                                DateTime(now.year, now.month, now.day)
                                    .add(const Duration(days: 7));
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController.value,
                    maxLines: null,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      border: const OutlineInputBorder(),
                      hintText: context.loc.description,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
