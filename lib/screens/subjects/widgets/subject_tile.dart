import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/baka_imported_icon.dart';
import 'package:schoolarc/widgets/subject_shortcut.dart';

class SubjectTile extends StatelessWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    required this.onTap,
    required this.onDelete,
    this.usedTimes,
  });

  final Subject subject;
  final int? usedTimes;
  final void Function() onTap;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final showDragHandle =
        platform == .windows || platform == .linux || platform == .macOS;

    return LayoutBuilder(
      builder: (context, constraints) {
        final debug = settings.get(Setting.debugMode);
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
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onErrorContainer,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                      flex: 10,
                    ),
                  ],
                )
              : null,
          child: Material(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (debug) Text(subject.order.toString()),
                    SizedBox(
                      width: 50,
                      child: SubjectShortcut(subject: subject),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(subject.name),
                    ),
                    if (subject.isFromBakalari)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          BakaImportedIcon(color: context.col.surfaceBright),
                          if (debug)
                            Text(
                              subject.bakaId ?? '',
                            ),
                        ],
                      ),
                    if (showDragHandle) const SizedBox(width: 28),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
