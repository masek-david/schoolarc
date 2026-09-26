import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schoolarc/features/subjects/presentation/select_subject_dialog.dart';
import 'package:schoolarc/l10n/app_localizations.dart';
import 'package:schoolarc/mock_data/mock_data.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';

import '../../../helpers/pump_app_extension.dart';

void main() {
  Future<BuildContext> getContext(WidgetTester tester) async {
    await tester.pumpApp(Container());
    return tester.element(find.byType(Container));
  }

  testWidgets(
    'Shows the dialog',
    (tester) async {
      final context = await getContext(tester);

      showSelectSubject(
        context: context,
        subjects: MockData.subjects.values.toList(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SelectSubjectDialog), findsOne);
    },
  );

  testWidgets(
    'Cancel doesnt return subject',
    (tester) async {
      final context = await getContext(tester);

      final resultFuture = showSelectSubject(
        context: context,
        subjects: MockData.subjects.values.toList(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final result = await resultFuture;
      expect(result, null);
      expect(find.byType(SelectSubjectDialog), findsNothing);
    },
  );

  testWidgets(
    'Tapping on subject returns the subject',
    (tester) async {
      final context = await getContext(tester);

      final resultFuture = showSelectSubject(
        context: context,
        subjects: MockData.subjects.values.toList(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chemistry'));
      await tester.pumpAndSettle();

      final result = await resultFuture;

      expect(
        result,
        isA<Subject>()
            .having((x) => x.id, 'id', '2')
            .having((x) => x.bakaId, 'bakaId', '2')
            .having((x) => x.name, 'name', 'Chemistry')
            .having((x) => x.shortcut, 'shortcut', 'Ch')
            .having((x) => x.order, 'order', 2)
            .having((x) => x.isDeleted, 'isDeleted', false),
      );
      expect(find.byType(SelectSubjectDialog), findsNothing);
    },
  );

  testWidgets(
    'Searching for the subject returns the subject',
    (tester) async {
      final context = await getContext(tester);

      final resultFuture = showSelectSubject(
        context: context,
        subjects: MockData.subjects.values.toList(),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.byKey(const Key('search')),
      );
      expect(textField.focusNode!.hasFocus, isTrue);

      await tester.enterText(find.byKey(const Key('search')), 'Chemis');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final result = await resultFuture;

      expect(
        result,
        isA<Subject>()
            .having((x) => x.id, 'id', '2')
            .having((x) => x.bakaId, 'bakaId', '2')
            .having((x) => x.name, 'name', 'Chemistry')
            .having((x) => x.shortcut, 'shortcut', 'Ch')
            .having((x) => x.order, 'order', 2)
            .having((x) => x.isDeleted, 'isDeleted', false),
      );
      expect(find.byType(SelectSubjectDialog), findsNothing);
    },
  );

  testWidgets(
    'Renders the subjects',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: SelectSubjectDialog(
            subjects: MockData.subjects.values.toList(),
          ),
        ),
      );

      expect(find.byType(SelectSubjectDialog), findsOne);

      expect(find.text('Select a subject:'), findsOne);
      expect(find.text('Mathematics'), findsOne);
      expect(find.text('Physics'), findsOne);
    },
  );
}
