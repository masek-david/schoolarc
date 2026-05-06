import 'package:flutter/material.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/utils/fonts.dart';

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
        style: googleSansFlex(
          size: 18,
          weight: 600,
          width: 80,
          roundness: 100,
          color: color ?? Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
