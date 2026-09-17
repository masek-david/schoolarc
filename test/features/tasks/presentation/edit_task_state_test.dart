import 'package:flutter_test/flutter_test.dart';
import 'package:schoolarc/features/tasks/presentation/edit_task_state.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/task_data_model.dart';

void main() {
  group('EditTaskState Unit Tests', () {
    late TaskData mockInitialTask;

    setUp(() {
      // Set a fixed historical timestamp so we can verify createTask generates a new one
      mockInitialTask = TaskData.empty().copyWith(
        id: '123',
        text: 'Initial Name',
        description: 'Initial Description',
        priority: 1,
        subjectId: '0',
        date: Date.today(),
        timestamp: DateTime.utc(2023, 1, 1),
      );
    });

    test('constructor correctly maps initialTask properties to state', () {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: mockInitialTask,
        isHomework: true,
      );

      // Verifies the initialization list lines run correctly
      expect(state.name.text, 'Initial Name');
      expect(state.description.text, 'Initial Description');
      expect(state.priority, 1);
      expect(state.subjectId, '0');
      expect(state.date, Date.today());
      expect(state.isHomework, isTrue);
      expect(state.autoSetDateToNextSubjectDate, isTrue);
      
      state.dispose();
    });

    test('hasUnsavedData returns false when no properties are changed', () {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: mockInitialTask,
        isHomework: true,
      );

      expect(state.hasUnsavedData(), isFalse);
      state.dispose();
    });

    // The next 5 tests ensure 100% branch coverage for the multi-part OR (||) statement
    test('hasUnsavedData returns true when ONLY name changes', () {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: mockInitialTask,
        isHomework: true,
      );

      state.name.text = 'New Name';
      expect(state.hasUnsavedData(), isTrue);
      state.dispose();
    });

    test('hasUnsavedData returns true when ONLY description changes', () {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: mockInitialTask,
        isHomework: true,
      );

      state.description.text = 'New Description';
      expect(state.hasUnsavedData(), isTrue);
      state.dispose();
    });

    test('hasUnsavedData returns true when ONLY priority changes', () {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: mockInitialTask,
        isHomework: true,
      );

      state.priority = 3;
      expect(state.hasUnsavedData(), isTrue);
      state.dispose();
    });

    test('hasUnsavedData returns true when ONLY subjectId changes', () {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: mockInitialTask,
        isHomework: true,
      );

      state.subjectId = 'new_subject';
      expect(state.hasUnsavedData(), isTrue);
      state.dispose();
    });

    test('hasUnsavedData returns true when ONLY date changes', () {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: mockInitialTask,
        isHomework: true,
      );

      state.date = Date.today().addDays(5);
      expect(state.hasUnsavedData(), isTrue);
      state.dispose();
    });

    test('createTask returns updated TaskData and generates a fresh UTC timestamp', () {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: mockInitialTask,
        isHomework: true,
      );

      // Modify every editable field
      state.name.text = 'Updated Name';
      state.description.text = 'Updated Description';
      state.priority = 3;
      state.subjectId = '1';
      state.date = Date.today().addDays(1);

      final newTask = state.createTask();

      // Unchanged fields should remain identical
      expect(newTask.id, '123'); 

      // Changed fields should map correctly
      expect(newTask.text, 'Updated Name');
      expect(newTask.description, 'Updated Description');
      expect(newTask.priority, 3);
      expect(newTask.subjectId, '1');
      expect(newTask.date, Date.today().addDays(1));
      
      // Verifies the specific line: timestamp: DateTime.now().toUtc()
      expect(newTask.timestamp.isAfter(mockInitialTask.timestamp), isTrue);
      expect(newTask.timestamp.isUtc, isTrue);

      state.dispose();
    });

    test('dispose executes cleanly and unmounts controllers', () {
      final state = EditTaskState(
        autoSetDateToNextSubjectDate: true,
        initialTask: mockInitialTask,
        isHomework: true,
      );

      // Calling this covers the two dispose() lines in your file
      state.dispose();

      // In Flutter, accessing a disposed TextEditingController throws an exception.
      // This assertion proves the dispose logic actually fired on the controllers.
      expect(() => state.name.text = 'test', throwsAssertionError);
      expect(() => state.description.text = 'test', throwsAssertionError);
    });
  });
}