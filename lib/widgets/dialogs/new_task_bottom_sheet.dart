import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
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
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';
import 'package:schoolarc/widgets/dialogs/subject_picker.dart';
import 'package:schoolarc/widgets/keyboard_date_picker/keyboard_date_picker.dart';
import 'package:schoolarc/widgets/priority_picker.dart';

// TODO when a dialog is opened over the sheet, the backgesture still animates the sheet, not the dialog

// TODO test on big screen
class NewTaskBottomSheet extends ConsumerStatefulWidget {
  const NewTaskBottomSheet({
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
  ConsumerState<NewTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<NewTaskBottomSheet>
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
  bool canPop = true;
  final _timetable = timetableDb.timeTable;

  /// These are used to make subject chips visible
  /// The map is id of subject to its globalkey
  Map<String, GlobalKey> subjectChipsKeys = {};

  /// [saveAsOtherType] saves the homework as exam and vice versa
  void onSave({bool saveAsOtherType = false}) {
    vibrate.heavy();
    final task = initialTask.copyWith(
      subjectId: pickedSubjectId.value,
      text: nameController.value.text,
      description: descriptionController.value.text,
      date: pickedDate.value,
      priority: pickedPriority.value,
      timestamp: DateTime.now().toUtc(),
    );

    final saveAsHomework = saveAsOtherType
        ? !widget.isHomework
        : widget.isHomework;

    if (saveAsHomework) {
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

    Navigator.pop(context);
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
      canPop = _getCanPop();
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

  /// Shows a date picker dialog
  void pickDate({bool keyboard = false}) async {
    final initial = pickedDate.value.toDateTimeLocal();
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

    setState(() {
      dateIsAutoSet.value = false;
      pickedDate.value = newDate;
      canPop = _getCanPop();
    });
  }

  /// Shows a select subject dialog and sets the state
  void pickSubject(List<Subject> subjects) async {
    final newSubject = await showSelectSubject(
      context: context,
      subjects: subjects,
    );

    setSubject(newSubject);
  }

  void showPopDialog() async {
    final popAllowed = await showMyDialog(
      dismissible: false,
      context: context,
      title: 'Discard edit?',
      actions: [
        DialogActionButton(
          text: 'Cancel',
          onPressed: () => Navigator.pop(context, false),
        ),
        DialogActionButton(
          isDestructiveAction: true,
          text: 'Discard',
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (popAllowed == true && mounted) {
      Navigator.pop(context);
    }
  }

  void showQr() {
    final task = initialTask.copyWith(
      subjectId: pickedSubjectId.value,
      text: nameController.value.text,
      description: descriptionController.value.text,
      date: pickedDate.value,
      priority: pickedPriority.value,
      timestamp: DateTime.now().toUtc(),
    );

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
                // TODO tofirejson cant be used, we need the subject name not id
                data: task.toHw().toFireJson().toString(),
                errorCorrectLevel: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns true only if the current form is the same with the initial task
  bool _getCanPop() {
    if (nameController.value.text != initialTask.text) return false;
    if (descriptionController.value.text != initialTask.description) {
      return false;
    }
    if (pickedPriority.value != initialTask.priority) return false;
    if (pickedSubjectId.value != initialTask.subjectId) return false;
    if (pickedDate.value != initialTask.date) return false;
    if (pickedDate.value != initialTask.date) return false;
    return true;
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

    final viewInsets = MediaQuery.of(context).viewInsets;
    final radii = MediaQuery.displayCornerRadiiOf(context);
    final today = Date.today();

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showPopDialog();
      },
      child: Material(
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
                  pickedPriority.value =
                      (intent as PickPriorityIntent).priority;
                }),
              ),
              PickDateIntent: CallbackAction(
                onInvoke: (intent) => pickDate(keyboard: true),
              ),
              PickSubjectIntent: CallbackAction(
                onInvoke: (intent) => pickSubject(subjects),
              ),
            },
            child: Column(
              mainAxisSize: .min,
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                          label: context.loc.save,
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
                              label: widget.isHomework
                                  ? context.loc.saveAsExam
                                  : context.loc.saveAsHomework,
                            ),
                            M3ESplitButtonItem(
                              value: 'qr',
                              icon: Icons.qr_code_rounded,
                              label: context.loc.shareByQr,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: .only(
                      topLeft: const .circular(28),
                      topRight: const .circular(28),
                      bottomLeft: viewInsets.bottom == 0
                          ? radii?.bottomLeft ?? const .circular(0)
                          : const .circular(0),
                      bottomRight: viewInsets.bottom == 0
                          ? radii?.bottomRight ?? const .circular(0)
                          : const .circular(0),
                    ),
                    color: context.col.surface,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                decoration: InputDecoration(
                                  hintText: context.loc.newTaskTextFieldHint,
                                ),
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
                                  setState(() {
                                    canPop = _getCanPop();
                                  });
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
                              return subject.containsText(
                                textEditingValue.text,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      // M3EToggleButtonGroup(
                      //   selectedIndex: pickedPriority.value,
                      //   onSelectedIndexChanged: (value) => setState(() {
                      //     if (value == null) return;
                      //     pickedPriority.value = value;
                      //   }),
                      //   spacing: 2,
                      //   actions: List.generate(
                      //     4,
                      //     (index) {
                      //       final p = TaskPriority(index);

                      //       return M3EToggleButtonGroupAction(
                      //         icon: PriorityIcon(
                      //           priority: index,
                      //           color: pickedPriority.value == index
                      //               ? p.getOnColor(context)
                      //               : p.getOnSurfaceColor(context),
                      //         ),
                      //         decoration: M3EToggleButtonDecoration(
                      //           foregroundColor: WidgetStateMapper({
                      //             WidgetState.selected: p.getOnColor(context),
                      //             WidgetState.any: p.getOnSurfaceColor(context),
                      //           }),
                      //           backgroundColor: WidgetStateMapper({
                      //             WidgetState.selected: p.getColor(context),
                      //             WidgetState.any: p.getSurfaceColor(context),
                      //           }),
                      //         ),
                      //         label: Text(p.name(context)),
                      //       );
                      //     },
                      //   ),
                      // ),
                      PriorityPicker(
                        selectedPriority: pickedPriority.value,
                        onSelected: (value) {
                          setState(() {
                            pickedPriority.value = value;
                            canPop = _getCanPop();
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
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Text(
                                  dateIsAutoSet.value
                                      ? '${context.loc.next} ${subjects.where((element) => element.id == pickedSubjectId.value).firstOrNull?.name}:'
                                      : context.loc.deadline,
                                  style: context.txt.titleMedium,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Text(
                                  pickedDate.value.formatFromSettings(
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
                      M3EToggleButtonGroup(
                        size: .sm,
                        style: .filled,
                        selectedIndex: switch (pickedDate.value) {
                          final d when d == today => 0,
                          final d when d == today.addDays(1) => 1,
                          final d when d == today.addDays(7) => 2,
                          _ => null,
                        },
                        onSelectedIndexChanged: (value) {
                          if (value == null) return;
                          vibrate.medium();
                          final daysToAdd = switch (value) {
                            1 => 1,
                            2 => 7,
                            _ => 0,
                          };

                          setState(() {
                            pickedDate.value = Date.today().addDays(daysToAdd);
                            canPop = _getCanPop();
                          });
                        },
                        actions: [
                          M3EToggleButtonGroupAction(
                            label: Text(context.loc.today),
                          ),
                          M3EToggleButtonGroupAction(
                            label: Text(context.loc.tomorrow),
                          ),
                          M3EToggleButtonGroupAction(
                            label: Text(
                              '${context.loc.next} ${DateFormat.EEEE(context.locale.languageCode).format(DateTime.now()).toLowerCase()}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController.value,
                        onChanged: (value) => setState(() {
                          canPop = _getCanPop();
                        }),
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: context.loc.description,
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
    );
  }
}
