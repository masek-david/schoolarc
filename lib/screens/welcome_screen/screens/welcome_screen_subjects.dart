
import 'package:flutter/material.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';
import 'package:school_manager/tasks_app.dart';

class WelcomeScreenSubjects extends StatelessWidget {
  const WelcomeScreenSubjects({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
      Subject(
        name: 'Name of the subject',
        shortcut: 'Short',
        id: '0',
        isDeleted: false,
        bakaId: null,
        timestamp: DateTime.now().toUtc(),
        order: 0,
      ),
      Subject(
        name: 'And another subject',
        shortcut: 'Math',
        id: '1',
        isDeleted: false,
        bakaId: null,
        timestamp: DateTime.now().toUtc(),
        order: 0,
      ),
      Subject(
        name: 'You can delete and edit the same way as tasks (taping and sliding)',
        shortcut: 'Edit',
        id: '2',
        isDeleted: false,
        bakaId: null,
        timestamp: DateTime.now().toUtc(),
        order: 0,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Each homework and exam can be have one subject:',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'You can create subjects in Subjects page in the drawer',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: subjects.map(
                (e) {
                  return SubjectTile(
                    subject: e,
                    onTap: () => showMessage(context, 'Now you could edit'),
                    onDelete: () => showMessage(
                        context, 'Now the subject would be deleted'),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 50),
            const Text(
              'You can assign the subject when adding new task or editing old',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
