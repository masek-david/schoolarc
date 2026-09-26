import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schoolarc/features/subjects/presentation/select_subject_dialog.dart';
import 'package:schoolarc/features/subjects/presentation/subject_picker.dart';
import 'package:schoolarc/mock_data/mock_data.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';

import '../../../helpers/pump_app_extension.dart';

void main() {
  testWidgets(
    'Shows the subjects',
    (tester) async {
      await tester.pumpApp(
        SubjectPicker(
          subjects: MockData.subjects.values.toList(),
          pickedSubjectId: null,
          onSelected: (subject) {},
        ),
      );

      expect(find.text('Mathematics'), findsOne);
      expect(find.text('Physics'), findsOne);
      expect(find.text('Chemistry'), findsOne);
    },
  );

  testWidgets(
    'Shows selected as highlighted',
    (tester) async {
      await tester.pumpApp(
        SubjectPicker(
          subjects: MockData.subjects.values.toList(),
          pickedSubjectId: '0',
          onSelected: (subject) {},
        ),
      );

      final chipSelected = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Mathematics'),
      );
      final chipUnselected = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Physics'),
      );
      expect(chipSelected.selected, isTrue);
      expect(chipUnselected.selected, isFalse);
    },
  );

  testWidgets(
    'Onselected returns the subject',
    (tester) async {
      Subject? result;
      await tester.pumpApp(
        SubjectPicker(
          subjects: MockData.subjects.values.toList(),
          pickedSubjectId: null,
          onSelected: (subject) {
            result = subject;
          },
        ),
      );

      await tester.tap(find.text('Chemistry'));

      expect(
        result,
        isA<Subject>()
            .having((s) => s.id, 'id', '2')
            .having((s) => s.name, 'name', 'Chemistry')
            .having((s) => s.shortcut, 'shortcut', 'Ch'),
      );
    },
  );

  testWidgets(
    'Onselected returns null when tapping on already selected subject',
    (tester) async {
      Subject? result = MockData.subjects['0'];
      await tester.pumpApp(
        SubjectPicker(
          subjects: MockData.subjects.values.toList(),
          pickedSubjectId: '0',
          onSelected: (subject) {
            result = subject;
          },
        ),
      );

      await tester.tap(find.text('Mathematics'));

      expect(result, isNull);
    },
  );

  testWidgets(
    'Tapping search opens dialog',
    (tester) async {
      await tester.pumpApp(
        SubjectPicker(
          subjects: MockData.subjects.values.toList(),
          pickedSubjectId: null,
          onSelected: (subject) {},
        ),
      );

      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(SelectSubjectDialog), findsOne);
    },
  );
}
