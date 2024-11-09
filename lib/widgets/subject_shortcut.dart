import 'package:flutter/material.dart';
import 'package:school_manager/data/subjects_data/subject_dto_model.dart';

class SubjectShortcut extends StatelessWidget {
  const SubjectShortcut({
    super.key,
    required this.subject,
    this.color,
  });

  final SubjectDTO? subject;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        subject?.trimmedShortcut ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
