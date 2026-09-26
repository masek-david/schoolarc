import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schoolarc/features/tasks/presentation/edit_task_bottom_sheet.dart';
import 'package:schoolarc/features/tasks/task_functions.dart';
import 'package:schoolarc/features/timetable/providers/timetable_notifier.dart';
import 'package:schoolarc/mock_data/mock_data.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';

import '../../helpers/mock_notifiers.dart';
import '../../helpers/pump_app_extension.dart';

void main() {
  late HwNotiferMock hwNotifier;
  late ExamNotiferMock examNotifier;

  final exam = MockData.exams['0']!.convert('0', MockData.subjects['0']);
  final hw = MockData.hws['0']!.convert('0', MockData.subjects['0']);

  setUp(() {
    hwNotifier = HwNotiferMock();
    examNotifier = ExamNotiferMock();
    when(() => hwNotifier.create(any())).thenAnswer((_) async {});
    when(() => hwNotifier.update(any())).thenAnswer((_) async {});
    when(() => hwNotifier.convert(any())).thenAnswer((_) async {});
    when(() => hwNotifier.delete(any())).thenAnswer((_) async {});
    when(() => hwNotifier.revertDelete(any())).thenAnswer((_) async {});
    when(() => hwNotifier.complete(any(), any())).thenAnswer((_) async {});
    when(() => examNotifier.create(any())).thenAnswer((_) async {});
    when(() => examNotifier.update(any())).thenAnswer((_) async {});
    when(() => examNotifier.convert(any())).thenAnswer((_) async {});
    when(() => examNotifier.delete(any())).thenAnswer((_) async {});
    when(() => examNotifier.revertDelete(any())).thenAnswer((_) async {});
  });

  Future<BuildContext> buildForContext(
    WidgetTester tester, {
    void Function(WidgetRef ref)? onRefGet,
  }) {
    return tester.pumpAppWithContext(
      Scaffold(
        body: Consumer(
          builder: (context, ref, child) {
            if (onRefGet != null) onRefGet(ref);
            return const SizedBox.shrink();
          },
        ),
      ),
      overrides: [
        hwDataProvider.overrideWith(() => hwNotifier),
        examDataProvider.overrideWith(() => examNotifier),
        subjectsSortedProvider.overrideWithValue(
          MockData.subjects.values.toList(),
        ),
        timetableProvider.overrideWithValue(MockData.timetable),
      ],
    );
  }

  testWidgets(
    'addNewHw shows the bottom sheet',
    (tester) async {
      final context = await buildForContext(tester);

      addNewHw(context);
      await tester.pumpAndSettle();

      expect(find.byType(EditTaskBottomSheet), findsOne);
    },
  );

  testWidgets(
    'addNewExam with initial date shows the bottom sheet with the initial date',
    (tester) async {
      final context = await buildForContext(tester);

      final date = Date.today().addDays(2);
      addNewExam(context, initialDate: date);
      await tester.pumpAndSettle();

      expect(find.text(date.format('EEE M/d', 'en')), findsOne);
    },
  );

  testWidgets(
    'editHw has the correct hw',
    (tester) async {
      final context = await buildForContext(tester);

      editHw(context, hw);
      await tester.pumpAndSettle();

      expect(find.text('Linear equations worksheet'), findsOne);
    },
  );

  testWidgets(
    'editExam has the correct exam',
    (tester) async {
      final context = await buildForContext(tester);

      editExam(context, exam);
      await tester.pumpAndSettle();

      expect(find.text('Algebra test'), findsOne);
    },
  );

  testWidgets(
    'The editing state is not lost on dismiss',
    (tester) async {
      final context = await buildForContext(tester);

      addNewHw(context);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('nameTextField')), 'Test123');
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Test123'), findsOne);
    },
  );

  testWidgets(
    'The editing state is lost correctly when dismissed',
    (tester) async {
      final context = await buildForContext(tester);

      addNewHw(context);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('nameTextField')), 'Test123');
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      await tester.pump(
        const Duration(seconds: 1),
      ); // we have to wait before the taskeditstate disposes, it has 1 second delay

      expect(find.byType(EditTaskBottomSheet), findsNothing);
    },
  );
  
  testWidgets(
    'completeHw calls complete',
    (tester) async {
      late WidgetRef ref;
      await buildForContext(tester, onRefGet: (r) => ref = r);

      completeHw(ref, hw, true);

      verify(() => hwNotifier.complete(any(), any())).called(1);
    },
  );

  testWidgets(
    'convertHw calls convert',
    (tester) async {
      late WidgetRef ref;
      await buildForContext(tester, onRefGet: (r) => ref = r);

      convertHw(ref, hw);

      verify(() => hwNotifier.convert(any())).called(1);
    },
  );

  testWidgets(
    'deleteHw calls delete and can be reverted',
    (tester) async {
      late WidgetRef ref;
      final context = await buildForContext(tester, onRefGet: (r) => ref = r);

      deleteHw(context, ref, hw);

      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));

      verify(() => hwNotifier.delete(any())).called(1);
      verify(() => hwNotifier.revertDelete(any())).called(1);
    },
  );

  testWidgets(
    'convertExam calls convert',
    (tester) async {
      late WidgetRef ref;
      await buildForContext(tester, onRefGet: (r) => ref = r);

      convertExam(ref, exam);

      verify(() => examNotifier.convert(any())).called(1);
    },
  );

  testWidgets(
    'deleteExam calls delete and can be reverted',
    (tester) async {
      late WidgetRef ref;
      final context = await buildForContext(tester, onRefGet: (r) => ref = r);

      deleteExam(context, ref, exam);

      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));

      verify(() => examNotifier.delete(any())).called(1);
      verify(() => examNotifier.revertDelete(any())).called(1);
    },
  );
}
