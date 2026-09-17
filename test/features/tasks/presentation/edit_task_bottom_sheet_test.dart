import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/features/tasks/presentation/edit_task_bottom_sheet.dart';
import 'package:schoolarc/features/tasks/presentation/edit_task_state.dart';
import 'package:schoolarc/l10n/app_localizations.dart';
import 'package:schoolarc/mock_data/mock_data.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_data_model.dart';
import 'package:schoolarc/models/homeworks/hw_data_model.dart';
import 'package:schoolarc/models/task_data_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/vibrate.dart';
import 'package:schoolarc/widgets/dialogs/subject_picker.dart';
import 'package:schoolarc/widgets/priority_picker.dart';

class HwNotiferMock extends Notifier<Map<String, HomeworkData>>
    with Mock
    implements HwNotifier {}

class ExamNotiferMock extends Notifier<Map<String, ExamData>>
    with Mock
    implements ExamNotifier {}

void main() {
  late Date today;
  late Date tomorrow;
  late Date nextWeek;
  late HwNotiferMock hwNotifier;
  late ExamNotiferMock examNotifier;

  setUpAll(() {
    Vibrate.createEmptyForTest();
    registerFallbackValue(TaskData.empty().toHw());
    registerFallbackValue(TaskData.empty().toExam());

    settings = SettingsDatabase(testingMode: true);

    today = Date.today();
    tomorrow = today.addDays(1);
    nextWeek = today.addDays(7);
  });

  setUp(() {
    hwNotifier = HwNotiferMock();
    examNotifier = ExamNotiferMock();
    when(() => hwNotifier.create(any())).thenAnswer((_) async {});
    when(() => hwNotifier.update(any())).thenAnswer((_) async {});
    when(() => examNotifier.create(any())).thenAnswer((_) async {});
    when(() => examNotifier.update(any())).thenAnswer((_) async {});
  });

  Widget buildSheet(EditTaskState? state) {
    return ProviderScope(
      overrides: [
        hwDataProvider.overrideWith(() => hwNotifier),
        examDataProvider.overrideWith(() => examNotifier),
        subjectsSortedProvider.overrideWithValue(
          MockData.subjects.values.toList(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: EditTaskBottomSheet(
          state:
              state ??
              EditTaskState(
                autoSetDateToNextSubjectDate: true,
                initialTask: TaskData.empty(),
                isHomework: true,
              ),
        ),
      ),
    );
  }

  testWidgets(
    'Creating a new homework',
    (tester) async {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: TaskData.empty(),
        isHomework: true,
      );

      await tester.pumpWidget(buildSheet(state));

      await tester.tap(find.text('Mathematics'));
      await tester.enterText(
        find.byKey(
          const Key('nameTextField'),
        ),
        'Name 123',
      );
      await tester.tap(find.text('Medium'));
      await tester.tap(find.text('Tomorrow').first);
      await tester.enterText(
        find.byKey(
          const Key('descriptionTextField'),
        ),
        'Description 123',
      );
      await tester.pumpAndSettle();

      final subjectPicker = tester.widget<SubjectPicker>(
        find.byType(SubjectPicker),
      );
      expect(subjectPicker.pickedSubjectId, '0');
      expect(find.text('Name 123'), findsOne);
      final priorityPicker = tester.widget<PriorityPicker>(
        find.byType(PriorityPicker),
      );
      expect(priorityPicker.selectedPriority, 2);
      expect(find.text(tomorrow.format('EEE M/d', 'en')), findsOne);
      final daysPickButtons = tester.widget<M3EToggleButtonGroup>(
        find.byType(M3EToggleButtonGroup),
      );
      expect(daysPickButtons.selectedIndex, 1);
      expect(find.text('Description 123'), findsOne);

      await tester.tap(find.text('Save'));

      verifyNever(() => examNotifier.update(any()));
      verifyNever(() => examNotifier.create(any()));
      verifyNever(() => hwNotifier.update(any()));
      verify(
        () => hwNotifier.create(
          any(
            that: isA<HomeworkData>()
                .having((p0) => p0.subjectId, 'subjectId', '0')
                .having((p0) => p0.text, 'text', 'Name 123')
                .having((p0) => p0.priority, 'priority', 2)
                .having((p0) => p0.date, 'date', tomorrow)
                .having(
                  (p0) => p0.description,
                  'description',
                  'Description 123',
                )
                .having((p0) => p0.id, 'id', ''),
          ),
          addToEnd: true,
          syncWithFire: true,
        ),
      ).called(1);
    },
  );

  testWidgets(
    'Creating a new exam',
    (tester) async {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: TaskData.empty(),
        isHomework: false,
      );

      await tester.pumpWidget(buildSheet(state));

      await tester.tap(find.text('Physics'));
      await tester.enterText(
        find.byKey(
          const Key('nameTextField'),
        ),
        'Name 123',
      );
      await tester.tap(find.text('High'));
      await tester.tap(
        find.text('Next ${today.format('EEEE', 'en').toLowerCase()}').first,
      );
      await tester.enterText(
        find.byKey(
          const Key('descriptionTextField'),
        ),
        'Description 123',
      );
      await tester.pumpAndSettle();

      final subjectPicker = tester.widget<SubjectPicker>(
        find.byType(SubjectPicker),
      );
      expect(subjectPicker.pickedSubjectId, '1');
      expect(find.text('Name 123'), findsOne);
      final priorityPicker = tester.widget<PriorityPicker>(
        find.byType(PriorityPicker),
      );
      expect(priorityPicker.selectedPriority, 3);
      expect(find.text(nextWeek.format('EEE M/d', 'en')), findsOne);
      final daysPickButtons = tester.widget<M3EToggleButtonGroup>(
        find.byType(M3EToggleButtonGroup),
      );
      expect(daysPickButtons.selectedIndex, 2);
      expect(find.text('Description 123'), findsOne);

      await tester.tap(find.text('Save'));

      verifyNever(() => hwNotifier.update(any()));
      verifyNever(() => hwNotifier.create(any()));
      verifyNever(() => examNotifier.update(any()));
      verify(
        () => examNotifier.create(
          any(
            that: isA<ExamData>()
                .having((p0) => p0.subjectId, 'subjectId', '1')
                .having((p0) => p0.text, 'text', 'Name 123')
                .having((p0) => p0.priority, 'priority', 3)
                .having((p0) => p0.date, 'date', nextWeek)
                .having(
                  (p0) => p0.description,
                  'description',
                  'Description 123',
                )
                .having((p0) => p0.id, 'id', ''),
          ),
          addToEnd: true,
          syncWithFire: true,
        ),
      ).called(1);
    },
  );

  testWidgets(
    'Displays initial values and edits homework',
    (tester) async {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: false,
        isHomework: true,
        initialTask: TaskData.empty().copyWith(
          text: 'Name 123',
          date: today,
          description: 'Description 123',
          priority: 1,
          subjectId: '0',
          id: '123',
        ),
      );

      await tester.pumpWidget(buildSheet(state));

      var subjectPicker = tester.widget<SubjectPicker>(
        find.byType(SubjectPicker),
      );
      expect(subjectPicker.pickedSubjectId, '0');
      expect(find.text('Name 123'), findsOne);
      var priorityPicker = tester.widget<PriorityPicker>(
        find.byType(PriorityPicker),
      );
      expect(priorityPicker.selectedPriority, 1);
      expect(find.text(today.format('EEE M/d', 'en')), findsOne);
      var daysPickButtons = tester.widget<M3EToggleButtonGroup>(
        find.byType(M3EToggleButtonGroup),
      );
      expect(daysPickButtons.selectedIndex, 0);
      expect(find.text('Description 123'), findsOne);

      await tester.tap(find.text('Physics'));
      await tester.enterText(
        find.byKey(
          const Key('nameTextField'),
        ),
        'Name 1234',
      );
      await tester.tap(find.text('Medium'));
      await tester.tap(find.text('Tomorrow').first);
      await tester.enterText(
        find.byKey(
          const Key('descriptionTextField'),
        ),
        'Description 1234',
      );

      await tester.pumpAndSettle();

      subjectPicker = tester.widget<SubjectPicker>(
        find.byType(SubjectPicker),
      );
      expect(subjectPicker.pickedSubjectId, '1');
      expect(find.text('Name 1234'), findsOne);
      priorityPicker = tester.widget<PriorityPicker>(
        find.byType(PriorityPicker),
      );
      expect(priorityPicker.selectedPriority, 2);
      expect(find.text(tomorrow.format('EEE M/d', 'en')), findsOne);
      daysPickButtons = tester.widget<M3EToggleButtonGroup>(
        find.byType(M3EToggleButtonGroup),
      );
      expect(daysPickButtons.selectedIndex, 1);
      expect(find.text('Description 1234'), findsOne);

      await tester.tap(find.text('Save'));

      verifyNever(() => examNotifier.create(any()));
      verifyNever(() => examNotifier.update(any()));
      verifyNever(() => hwNotifier.create(any()));
      verify(
        () => hwNotifier.update(
          any(
            that: isA<HomeworkData>()
                .having((p0) => p0.id, 'id', '123')
                .having((p0) => p0.subjectId, 'subjectId', '1')
                .having((p0) => p0.text, 'text', 'Name 1234')
                .having((p0) => p0.priority, 'priority', 2)
                .having((p0) => p0.date, 'date', tomorrow)
                .having(
                  (p0) => p0.description,
                  'description',
                  'Description 1234',
                ),
          ),
          checkOrder: true,
          syncWithFire: true,
        ),
      ).called(1);
    },
  );

  testWidgets(
    'Displays initial values and edits exam',
    (tester) async {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: false,
        isHomework: false,
        initialTask: TaskData.empty().copyWith(
          text: 'Name 123',
          date: today,
          description: 'Description 123',
          priority: 1,
          subjectId: '0',
          id: '123',
        ),
      );

      await tester.pumpWidget(buildSheet(state));

      var subjectPicker = tester.widget<SubjectPicker>(
        find.byType(SubjectPicker),
      );
      expect(subjectPicker.pickedSubjectId, '0');
      expect(find.text('Name 123'), findsOne);
      var priorityPicker = tester.widget<PriorityPicker>(
        find.byType(PriorityPicker),
      );
      expect(priorityPicker.selectedPriority, 1);
      expect(find.text(today.format('EEE M/d', 'en')), findsOne);
      var daysPickButtons = tester.widget<M3EToggleButtonGroup>(
        find.byType(M3EToggleButtonGroup),
      );
      expect(daysPickButtons.selectedIndex, 0);
      expect(find.text('Description 123'), findsOne);

      await tester.tap(find.text('Physics'));
      await tester.enterText(
        find.byKey(
          const Key('nameTextField'),
        ),
        'Name 1234',
      );
      await tester.tap(find.text('Medium'));
      await tester.tap(find.text('Tomorrow').first);
      await tester.enterText(
        find.byKey(
          const Key('descriptionTextField'),
        ),
        'Description 1234',
      );

      await tester.pumpAndSettle();

      subjectPicker = tester.widget<SubjectPicker>(
        find.byType(SubjectPicker),
      );
      expect(subjectPicker.pickedSubjectId, '1');
      expect(find.text('Name 1234'), findsOne);
      priorityPicker = tester.widget<PriorityPicker>(
        find.byType(PriorityPicker),
      );
      expect(priorityPicker.selectedPriority, 2);
      expect(find.text(tomorrow.format('EEE M/d', 'en')), findsOne);
      daysPickButtons = tester.widget<M3EToggleButtonGroup>(
        find.byType(M3EToggleButtonGroup),
      );
      expect(daysPickButtons.selectedIndex, 1);
      expect(find.text('Description 1234'), findsOne);

      await tester.tap(find.text('Save'));

      verifyNever(() => hwNotifier.create(any()));
      verifyNever(() => hwNotifier.update(any()));
      verifyNever(() => examNotifier.create(any()));
      verify(
        () => examNotifier.update(
          any(
            that: isA<ExamData>()
                .having((p0) => p0.id, 'id', '123')
                .having((p0) => p0.subjectId, 'subjectId', '1')
                .having((p0) => p0.text, 'text', 'Name 1234')
                .having((p0) => p0.priority, 'priority', 2)
                .having((p0) => p0.date, 'date', tomorrow)
                .having(
                  (p0) => p0.description,
                  'description',
                  'Description 1234',
                ),
          ),
          checkOrder: true,
          syncWithFire: true,
        ),
      ).called(1);
    },
  );

  testWidgets(
    'Auto set date works when creating',
    (tester) async {
      await tester.pumpWidget(buildSheet(null));

      await tester.tap(find.text('Chemistry'));
      await tester.pumpAndSettle();
      expect(find.text('Next Chemistry'), findsOne);
      expect(
        find.text(
          MockData.timetable.nextDateForSubject('2')!.format('EEE M/d', 'en'),
        ),
        findsOne,
      );

      await tester.tap(find.text('Biology'));
      await tester.pumpAndSettle();
      expect(find.text('Next Biology'), findsOne);
      expect(
        find.text(
          MockData.timetable.nextDateForSubject('3')!.format('EEE M/d', 'en'),
        ),
        findsOne,
      );

      await tester.tap(find.text('Today').first);
      await tester.pump();
      expect(find.text(today.format('EEE M/d', 'en')), findsOne);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('Next English'), findsOne);
      expect(find.text(today.format('EEE M/d', 'en')), findsOne);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Next History'), findsOne);
      expect(find.text(today.format('EEE M/d', 'en')), findsOne);
    },
  );

  testWidgets(
    'Auto set date disabled when editing',
    (tester) async {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: false,
        initialTask: TaskData.empty(),
        isHomework: true,
      );

      await tester.pumpWidget(buildSheet(state));

      await tester.tap(find.text('Chemistry'));
      await tester.pumpAndSettle();
      expect(find.text('Next Chemistry'), findsOne);
      expect(find.text(today.format('EEE M/d', 'en')), findsOne);

      await tester.tap(find.text('Biology'));
      await tester.pumpAndSettle();
      expect(find.text('Next Biology'), findsOne);
      expect(find.text(today.format('EEE M/d', 'en')), findsOne);

      await tester.tap(find.text('Next Biology'));
      await tester.pumpAndSettle();
      expect(find.text('Next Biology'), findsOne);
      expect(
        find.text(
          MockData.timetable.nextDateForSubject('3')!.format('EEE M/d', 'en'),
        ),
        findsOne,
      );

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('Next English'), findsOne);
      expect(
        find.text(
          MockData.timetable.nextDateForSubject('4')!.format('EEE M/d', 'en'),
        ),
        findsOne,
      );

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Next History'), findsOne);
      expect(
        find.text(
          MockData.timetable.nextDateForSubject('5')!.format('EEE M/d', 'en'),
        ),
        findsOne,
      );
    },
  );

  testWidgets(
    'Date picker sets new date correctly',
    (tester) async {
      await tester.pumpWidget(buildSheet(null));

      await tester.tap(find.text(today.format('EEE M/d', 'en')));
      await tester.pumpAndSettle();

      expect(find.text('Select date'), findsOne);

      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(
        find.text(Date(today.year, today.month, 15).format('EEE M/d', 'en')),
        findsOne,
      );
    },
  );

  testWidgets(
    'Cancel button doesn\'t call save or edit',
    (tester) async {
      await tester.pumpWidget(buildSheet(null));

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      verifyNever(() => hwNotifier.create(any()));
      verifyNever(() => hwNotifier.update(any()));
      verifyNever(() => examNotifier.update(any()));
      verifyNever(() => examNotifier.create(any()));
    },
  );

  testWidgets(
    'Create homework save as exam',
    (tester) async {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: TaskData.empty(),
        isHomework: true,
      );

      await tester.pumpWidget(buildSheet(state));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save_as_rounded));
      await tester.pumpAndSettle();

      verifyNever(() => hwNotifier.create(any()));
      verifyNever(() => hwNotifier.update(any()));
      verifyNever(() => examNotifier.update(any()));
      verify(() => examNotifier.create(any())).called(1);
    },
  );

  testWidgets(
    'Create exam save as homework',
    (tester) async {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: TaskData.empty(),
        isHomework: false,
      );

      await tester.pumpWidget(buildSheet(state));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save_as_rounded));
      await tester.pumpAndSettle();

      verifyNever(() => examNotifier.create(any()));
      verifyNever(() => examNotifier.update(any()));
      verifyNever(() => hwNotifier.update(any()));
      verify(() => hwNotifier.create(any())).called(1);
    },
  );
}
