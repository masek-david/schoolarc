import 'package:flutter/material.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';
import 'package:school_manager/tasks_app.dart';

class WelcomeScreenSubjects extends StatelessWidget {
  const WelcomeScreenSubjects({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
      SubjectDTO(
        name: 'Name of the subject',
        shortcut: 'Short',
        dbIndex: 0,
      ),
      SubjectDTO(
        name: 'And another subject',
        shortcut: 'Math',
        dbIndex: 0,
      ),
      SubjectDTO(
        name: 'You can delete and edit the same way as tasks',
        shortcut: 'Edit',
        dbIndex: 0,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Each homework and exam can be assigned to one subject:',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'You can create more subjects in Subjects page in the drawer',
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
            SizedBox(height: 50),
            Text(
              'You can assign the subject when adding new task or editing old',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
