import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_data_model.dart';
import 'package:schoolarc/models/homeworks/hw_data_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/task_data_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/screens/timetable/select_subject.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/intent/intents.dart';
import 'package:schoolarc/widgets/buttons/cancel_save_button.dart';
import 'package:schoolarc/widgets/dialogs/subject_picker.dart';
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
  final Date? initialDate;

  /// if true, when a subject is selected, the date will be set to first appearance of this subject in constant timetable
  final bool autoSetDate;
  final bool isHomework;

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet>
    with RestorationMixin {
  late final initialTask =
      (widget.isHomework
          ? ref.read(hwDataProvider)[widget.initialTaskId]
          : ref.read(examDataProvider)[widget.initialTaskId]) ??
      TaskData.empty().copyWith(date: widget.initialDate);
  late final nameController = RestorableTextEditingController.fromValue(
    TextEditingValue(text: initialTask.text),
  );
  late final descriptionController = RestorableTextEditingController.fromValue(
    TextEditingValue(text: initialTask.description),
  );
  late RestorableStringN pickedSubjectId = RestorableStringN(
    initialTask.subjectId,
  );
  late RestorableDate pickedDate = RestorableDate(initialTask.date);
  late RestorableInt pickedPriority = RestorableInt(initialTask.priority);
  late RestorableBool group = RestorableBool(false);
  late RestorableBool dateIsAutoSet = RestorableBool(false);

  final _timetable = timetableDb.timeTable;

  /// These are used to make subject chips visible
  /// The map is id of subject to its globalkey
  Map<String, GlobalKey> subjectChipsKeys = {};

  void onSave() {
    vibrate.heavy();
    final task = initialTask.copyWith(
      subjectId: pickedSubjectId.value,
      text: nameController.value.text,
      description: descriptionController.value.text,
      date: pickedDate.value,
      priority: pickedPriority.value,
      timestamp: DateTime.now().toUtc(),
    );

    if (widget.isHomework) {
      if (task.id == '') {
        ref.read(hwDataProvider.notifier).create(task.toHw());
      } else {
        ref.read(hwDataProvider.notifier).update(task as HomeworkData);
      }
    } else {
      if (task.id == '') {
        ref.read(examDataProvider.notifier).create(task.toExam());
      } else {
        ref.read(examDataProvider.notifier).update(task as ExamData);
      }
    }
  }

  void setSubject(Subject? subject) {
    vibrate.medium();
    setState(() {
      pickedSubjectId.value = subject?.id;
      dateIsAutoSet.value = false;
      if (widget.autoSetDate && subject != null) {
        final newDate = _timetable.nextDateForSubject(subject);
        if (newDate != null) {
          dateIsAutoSet.value = true;
          pickedDate.value = newDate;
        }
      }
    });
    _subjectChipEnsureVisible(subject?.id);
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

  void pickDate({bool keyboard = false}) async {
    final initial = pickedDate.value.toDateTimeLocal();
    DateTime? newDate;
    if (keyboard) {
      newDate = await showDialog<DateTime?>(
        context: context,
        builder: (context) => KeyboardDatePicker(initialDate: initial),
      );
    } else {
      newDate = await showDatePicker(
        context: context,
        locale: Locale(
          Localizations.localeOf(context).languageCode,
          ref.watch(weekStartsOnMondayProvider) ? 'GB' : 'US',
        ),
        initialDate: initial,
        firstDate: DateTime.utc(0),
        lastDate: DateTime.utc(3000),
      );
    }

    if (newDate == null) return;

    setState(() {
      dateIsAutoSet.value = false;
      pickedDate.value = Date.fromDateTime(newDate!.toLocal());
    });
    return;
  }

  void pickSubject(List<Subject> subjects) async {
    final newSubject = await showSelectSubject(
      context: context,
      subjects: subjects,
    );

    setSubject(newSubject);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subjectChipEnsureVisible(pickedSubjectId.value);
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
    registerForRestoration(dateIsAutoSet, 'dateIsAutoSet');
    registerForRestoration(group, 'share');
  }

  @override
  Widget build(BuildContext context) {
    late List<Subject> subjects = ref.watch(subjectsSortedProvider);

    for (final subject in subjects) {
      subjectChipsKeys.putIfAbsent(subject.id, () => GlobalKey());
    }

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
            onInvoke: (intent) => pickSubject(subjects),
          ),
        },
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
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
                SubjectPicker(
                  subjects: subjects,
                  pickedSubjectId: pickedSubjectId.value,
                  onSelected: setSubject,
                  chipKeys: subjectChipsKeys,
                ),
                const SizedBox(height: 10),
                Autocomplete<Subject>(
                  fieldViewBuilder:
                      (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        return TextField(
                          controller: nameController.value,
                          focusNode: focusNode,
                          autofocus: true,
                          maxLines: null,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {
                            onFieldSubmitted();
                            if (nameController.value.text.isNotEmpty) {
                              Navigator.pop(context);
                              onSave();
                            }
                          },
                          onChanged: (value) {
                            textEditingController.text = value;
                          },
                          onEditingComplete: () {},
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
                const SizedBox(height: 4),
                PriorityPicker(
                  selectedPriority: pickedPriority.value,
                  onSelected: (value) {
                    setState(() {
                      pickedPriority.value = value;
                    });
                  },
                ),
                // SettingTile.withCheckbox(
                //   contentPadding: const EdgeInsets.all(0),
                //   title: 'Share',
                //   value: share.value,
                //   onChanged: (value) => setState(() {
                //     share.value = value;
                //   }),
                // ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: pickDate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dateIsAutoSet.value
                                ? '${context.loc.next} ${subjects.where((element) => element.id == pickedSubjectId.value).firstOrNull?.name}:'
                                : context.loc.deadline,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Text(
                          pickedDate.value.formatFromSettings(context),
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
                      selected: pickedDate.value.isSameDay(Date.today()),
                      onSelected: (value) {
                        vibrate.medium();
                        setState(() {
                          pickedDate.value = Date.today();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(context.loc.tomorrow),
                      selected: pickedDate.value.isSameDay(
                        Date.today().addDays(1),
                      ),
                      onSelected: (value) {
                        vibrate.medium();
                        setState(() {
                          pickedDate.value = Date.today().addDays(1);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(
                        '${context.loc.next} ${DateFormat.EEEE(context.locale.languageCode).format(DateTime.now()).toLowerCase()}',
                      ),
                      selected: pickedDate.value.isSameDay(
                        Date.today().addDays(7),
                      ),
                      onSelected: (value) {
                        vibrate.medium();
                        setState(() {
                          pickedDate.value = Date.today().addDays(7);
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
                    hintText: context.loc.description,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
