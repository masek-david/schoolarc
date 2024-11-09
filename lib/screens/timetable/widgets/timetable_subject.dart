import 'package:flutter/material.dart';
import 'package:school_manager/data/subjects_data/subject_dto_model.dart';
import 'package:school_manager/widgets/subject_shortcut.dart';

class TimetableSubject extends StatelessWidget {
  const TimetableSubject({
    super.key,
    required this.subject,
    required this.columnWidth,
    required this.onTap,
    required this.showName,
    this.isHighlighted = false,
  });

  final SubjectDTO? subject;
  final double columnWidth;
  final bool showName;
  final bool isHighlighted;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tileColor = isHighlighted ? colorScheme.primaryContainer : colorScheme.secondaryContainer;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: columnWidth,
          height: double.infinity,
          decoration: BoxDecoration(
            border: subject == null
                ? Border.all(
                    color: tileColor,
                    width: 2,
                  )
                : null,
            color: subject == null ? null : tileColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showName) const SizedBox(height: 10),
                    SubjectShortcut(subject: subject),
                    if (showName) const Spacer(),
                    if (showName)
                      Text(
                        subject?.name ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
