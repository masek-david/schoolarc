import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/subject_shortcut.dart';

class SubjectTile extends StatelessWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    required this.onTap,
    required this.onDelete,
  });

  final SubjectDTO subject;
  final void Function() onTap;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double extentRatio = 120 / constraints.maxWidth;

      if (extentRatio > 1) {
        extentRatio = 1;
      }

      return Slidable(
        groupTag: '1',
        endActionPane: onDelete != null
            ? ActionPane(
                motion: const StretchMotion(),
                extentRatio: extentRatio,
                children: [
                  SlidableAction(
                    onPressed: (context) => onDelete!(),
                    icon: Icons.delete,
                    foregroundColor:
                        Theme.of(context).colorScheme.onErrorContainer,
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                    flex: 10,
                  ),
                ],
              )
            : null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (settings.get(Setting.showDebugInfo))
                    Text(subject.dbIndex.toString()),
                  if (settings.get(Setting.showDebugInfo) && subject.isDeleted)
                    Icon(Icons.delete),
                  if (settings.get(Setting.showDebugInfo))
                    Text('order: ${subject.order.toString()}'),
                  SizedBox(
                    width: 50,
                    child: SubjectShortcut(subject: subject),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(subject.name),
                  ),
                  if (subject.isFromBakalari)
                    Icon(
                      Icons.hexagon,
                      color: Theme.of(context).colorScheme.surfaceBright,
                    ),
                  if (subject.isFromBakalari &&
                      settings.get(Setting.showDebugInfo))
                    Text(subject.bakaId ?? ''),
                  if (settings.get(Setting.showDebugInfo))
                    Text(subject.timestamp.millisecondsSinceEpoch.toString()),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
