import 'package:flutter/material.dart';
import 'package:school_manager/subjects/subject_model.dart';

class SubjectTile extends StatelessWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

  final Subject subject;
  final void Function() onEdit;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primary.withAlpha(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 50, child: Text(subject.shortcut)),
              Text(subject.name),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                label: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
              TextButton.icon(
                label: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
