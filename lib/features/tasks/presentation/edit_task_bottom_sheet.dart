import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:schoolarc/features/tasks/presentation/edit_task_state.dart';
import 'package:schoolarc/m3e/m3e_motion_curves.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/screens/timetable/select_subject.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/intent/intents.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';
import 'package:schoolarc/widgets/dialogs/subject_picker.dart';
import 'package:schoolarc/widgets/keyboard_date_picker/keyboard_date_picker.dart';
import 'package:schoolarc/widgets/priority_picker.dart';

class EditTaskBottomSheet extends ConsumerStatefulWidget {
  const EditTaskBottomSheet({super.key, required this.state});

  /// The editable state that should be kept
  final EditTaskState state;

  @override
  ConsumerState<EditTaskBottomSheet> createState() =>
      _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<EditTaskBottomSheet> {
  late final state = widget.state;
  final _timetable = timetableDb.timeTable;
  // final _timetable = MockData.timetable; // TODO mock timetable for testing

  /// The date for the next day of occurance of the currently selected date
  late Date? nextSubjectDate = _timetable.nextDateForSubject(state.subjectId);

  /// These are used to make subject chips visible
  /// The map is id of subject to its globalkey
  Map<String, GlobalKey> subjectChipsKeys = {};

  /// [saveAsOtherType] saves the homework as exam and vice versa
  void onSave({bool saveAsOtherType = false}) {
    vibrate.heavy();

    final saveAsHomework = saveAsOtherType
        ? !state.isHomework
        : state.isHomework;

    Posthog().capture(
      eventName: 'Saved ${saveAsHomework ? 'Homework' : 'Exam'}',
    );

    final task = state.createTask();

    // Whether to create a new task or edit an already existing task
    final shouldCreateNewTask = task.id == '';

    if (saveAsHomework) {
      if (shouldCreateNewTask) {
        ref.read(hwDataProvider.notifier).create(task.toHw());
      } else {
        ref.read(hwDataProvider.notifier).update(task.toHw());
      }
    } else {
      if (shouldCreateNewTask) {
        ref.read(examDataProvider.notifier).create(task.toExam());
      } else {
        ref.read(examDataProvider.notifier).update(task.toExam());
      }
    }

    // Pop with true to indicate saving success
    Navigator.pop(context, true);
  }

  /// Sets the subject, the [nextSubjectDate] and if allowed, changed the subject date
  void setSubject(Subject? subject) {
    vibrate.medium();

    setState(() {
      state.subjectId = subject?.id;
      nextSubjectDate = _timetable.nextDateForSubject(state.subjectId);
      if (state.autoSetDateToNextSubjectDate && nextSubjectDate != null) {
        state.date = nextSubjectDate!;
      }
    });
    _subjectChipEnsureVisible(subject?.id);
  }

  /// Shows a select subject dialog and sets the state
  void pickSubject(List<Subject> subjects) async {
    final newSubject = await showSelectSubject(
      context: context,
      subjects: subjects,
    );

    setSubject(newSubject);
  }

  /// Scroll the subject chips to ensure the subject with the provided id is visible
  void _subjectChipEnsureVisible(String? subjectId) {
    if (subjectId != null) {
      final chipContext = subjectChipsKeys[subjectId]?.currentContext;
      if (chipContext != null) {
        Scrollable.ensureVisible(
          chipContext,
          alignment: .1,
          duration: SpatialMotion.defaultMotion.duration,
          curve: SpatialMotion.defaultMotion.curve,
          // duration: const Duration(milliseconds: 500),
        );
      }
    }
  }

  /// Call when the user manually selected a date
  void setDate(Date date) {
    setState(() {
      state.autoSetDateToNextSubjectDate = false;
      state.date = date;
    });
  }

  /// Shows a date picker dialog
  void pickDate({bool keyboard = false}) async {
    final initial = state.date.toDateTimeLocal();
    DateTime? newDateTime;
    if (keyboard) {
      newDateTime = await showDialog<DateTime?>(
        context: context,
        builder: (context) => KeyboardDatePicker(initialDate: initial),
      );
    } else {
      newDateTime = await showDatePicker(
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

    if (newDateTime == null) return;
    final newDate = Date.fromDateTime(newDateTime.toLocal());
    setDate(newDate);
  }

  void showQr() {
    final task = state.createTask();

    showMyDialog(
      context: context,
      title: context.loc.scanQr,
      actions: [
        DialogActionButton(
          text: context.loc.close,
          onPressed: () => Navigator.pop(context),
        ),
      ],
      content: SizedBox(
        height: 160,
        child: Center(
          child: PrettyQrView(
            decoration: PrettyQrDecoration(
              shape: PrettyQrSmoothSymbol(
                color: context.col.primary,
              ),
            ),
            qrImage: QrImage(
              QrCode.fromData(
                // TODO tofirejson cant be used, we need the subject name not id and we need the link to open schoolarc app too
                data: task.toHw().toFireJson().toString(),
                errorCorrectLevel: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subjectChipEnsureVisible(state.subjectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    late List<Subject> subjects = ref.watch(subjectsSortedProvider);

    for (final subject in subjects) {
      subjectChipsKeys.putIfAbsent(subject.id, () => GlobalKey());
    }

    final viewPadding = MediaQuery.viewInsetsOf(context);
    final today = Date.today();

    final view = View.of(context);
    // mediaquery returns 0 here, idk why
    final topPadding = view.padding.top / view.devicePixelRatio;

    final loc = context.loc;

    return Material(
      color: Colors.transparent,
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.digit1,
          ): const PickPriorityIntent(
            0,
          ),
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.digit2,
          ): const PickPriorityIntent(
            1,
          ),
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.digit3,
          ): const PickPriorityIntent(
            2,
          ),
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.digit4,
          ): const PickPriorityIntent(
            3,
          ),
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.numpad1,
          ): const PickPriorityIntent(
            0,
          ),
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.numpad2,
          ): const PickPriorityIntent(
            1,
          ),
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.numpad3,
          ): const PickPriorityIntent(
            2,
          ),
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.numpad4,
          ): const PickPriorityIntent(
            3,
          ),
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyD,
          ): const PickDateIntent(),
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyF,
          ): const PickSubjectIntent(),
        },
        child: Actions(
          actions: {
            PickPriorityIntent: CallbackAction(
              onInvoke: (intent) => setState(() {
                state.priority = (intent as PickPriorityIntent).priority;
              }),
            ),
            PickDateIntent: CallbackAction(
              onInvoke: (intent) => pickDate(keyboard: true),
            ),
            PickSubjectIntent: CallbackAction(
              onInvoke: (intent) => pickSubject(subjects),
            ),
          },
          child: Padding(
            padding: .only(bottom: viewPadding.bottom),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: .min,
                children: [
                  SizedBox(
                    height: 72 + topPadding,
                    child: Stack(
                      alignment: .bottomCenter,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.all(8.0) +
                              .only(top: topPadding),
                          child: Row(
                            spacing: 8,
                            children: [
                              M3EIconButton(
                                style: .tonal,
                                size: .md,
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close_rounded),
                              ),
                              const Spacer(),
                              M3EFilledSplitButton(
                                size: .md,
                                leadingIcon: Icons.check_rounded,
                                label: loc.save,
                                onPressed: onSave,
                                onSelected: (value) {
                                  if (value == 'qr') showQr();
                                  if (value == 'saveAsOther') {
                                    onSave(saveAsOtherType: true);
                                  }
                                },
                                items: [
                                  M3ESplitButtonItem(
                                    value: 'saveAsOther',
                                    icon: Icons.save_as_rounded,
                                    label: state.isHomework
                                        ? loc.saveAsExam
                                        : loc.saveAsHomework,
                                  ),
                                  M3ESplitButtonItem(
                                    value: 'qr',
                                    icon: Icons.qr_code_rounded,
                                    label: loc.shareByQr,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: const .only(
                        topLeft: .circular(28),
                        topRight: .circular(28),
                      ),
                      color: context.col.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 0, 0),
                          child: SubjectPicker(
                            subjects: subjects,
                            pickedSubjectId: state.subjectId,
                            onSelected: setSubject,
                            chipKeys: subjectChipsKeys,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                          child: Autocomplete<Subject>(
                            fieldViewBuilder:
                                (
                                  context,
                                  textEditingController,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  return TextField(
                                    key: const Key('nameTextField'),
                                    decoration: InputDecoration(
                                      hintText: loc.newTaskTextFieldHint,
                                    ),
                                    controller: state.name,
                                    focusNode: focusNode,
                                    autofocus: true,
                                    maxLines: null,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (value) {
                                      onFieldSubmitted();
                                      if (state.name.text.isNotEmpty) {
                                        onSave();
                                      }
                                    },
                                    onChanged: (value) {
                                      textEditingController.text = value;
                                    },
                                    // This is here so the keyboar doesnt close when the user presse ok to select a subject
                                    onEditingComplete: () {},
                                  );
                                },
                            onSelected: (subject) {
                              state.name.text = '';
                              setSubject(subject);
                            },
                            displayStringForOption: (subject) {
                              return subject.name;
                            },
                            optionsBuilder: (textEditingValue) {
                              if (textEditingValue.text == '' ||
                                  state.subjectId != null) {
                                return const Iterable.empty();
                              }
                              return subjects.where(
                                (subject) {
                                  return subject.containsText(
                                    textEditingValue.text,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                          child: PriorityPicker(
                            selectedPriority: state.priority,
                            onSelected: (value) {
                              setState(() {
                                state.priority = value;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                          child: GestureDetector(
                            onTap: pickDate,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Expanded(
                                    child: Text(
                                      loc.deadline,
                                      style: context.txt.titleMedium,
                                    ),
                                  ),
                                  Padding(
                                    padding: const .fromLTRB(8, 16, 0, 16),
                                    child: Text(
                                      state.date.formatFromSettings(
                                        context,
                                        formatPrefix: 'EEE ',
                                      ),
                                      style: context.txt.headlineMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                          child: SizedBox(
                            height: 40,
                            child: SingleChildScrollView(
                              scrollDirection: .horizontal,
                              child: Row(
                                children: [
                                  const SizedBox(width: 4),
                                  AnimatedSize(
                                    duration:
                                        SpatialMotion.defaultMotion.duration,
                                    curve: SpatialMotion.defaultMotion.curve,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: SizedBox(
                                        width: nextSubjectDate == null
                                            ? 0
                                            : null,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          child: M3EToggleButton(
                                            decoration:
                                                M3EToggleButtonDecoration(
                                                  backgroundColor:
                                                      WidgetStateColor.fromMap({
                                                        WidgetState.selected:
                                                            context
                                                                .col
                                                                .tertiary,
                                                        WidgetState.any: context
                                                            .col
                                                            .surfaceContainer,
                                                      }),
                                                  foregroundColor:
                                                      WidgetStateColor.fromMap({
                                                        WidgetState.selected:
                                                            context
                                                                .col
                                                                .onTertiary,
                                                        WidgetState.any: context
                                                            .col
                                                            .onSurface,
                                                      }),
                                                ),
                                            style: .filled,
                                            checked:
                                                state.date == nextSubjectDate,
                                            onCheckedChange: (value) {
                                              vibrate.medium();
                                              if (nextSubjectDate != null) {
                                                setState(() {
                                                  state.autoSetDateToNextSubjectDate =
                                                      true;
                                                  state.date = nextSubjectDate!;
                                                });
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.auto_awesome_rounded,
                                            ),
                                            label: Text(
                                              '${loc.next} ${subjects.where((element) => element.id == state.subjectId).firstOrNull?.name}',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  M3EToggleButtonGroup(
                                    size: .sm,
                                    style: .filled,
                                    selectedIndex: switch (state.date) {
                                      final d when d == today => 0,
                                      final d when d == today.addDays(1) => 1,
                                      final d when d == today.addDays(7) => 2,
                                      _ => null,
                                    },
                                    onSelectedIndexChanged: (value) {
                                      if (value == null) { // the already chosen date has been tapped -> the user HAS picked a date -> disable autoset
                                        setState(() {
                                          state.autoSetDateToNextSubjectDate =
                                              false;
                                        });
                                        return;
                                      }
                                      vibrate.medium();
                                      final daysToAdd = switch (value) {
                                        1 => 1,
                                        2 => 7,
                                        _ => 0,
                                      };
                                      setDate(Date.today().addDays(daysToAdd));
                                    },
                                    actions: [
                                      M3EToggleButtonGroupAction(
                                        label: Text(loc.today),
                                      ),
                                      M3EToggleButtonGroupAction(
                                        label: Text(loc.tomorrow),
                                      ),
                                      M3EToggleButtonGroupAction(
                                        label: Text(
                                          '${loc.next} ${DateFormat.EEEE(context.locale.languageCode).format(DateTime.now()).toLowerCase()}',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                          child: TextField(
                            key: const Key('descriptionTextField'),
                            controller: state.description,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: loc.description,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
