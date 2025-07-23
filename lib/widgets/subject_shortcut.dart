import 'package:flutter/material.dart';
import 'package:school_manager/models/subjects/subject_model.dart';

class SubjectShortcut extends StatelessWidget {
  const SubjectShortcut({
    super.key,
    required this.subject,
    this.color,
  });

  final Subject? subject;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        subject?.trimmedShortcut ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
