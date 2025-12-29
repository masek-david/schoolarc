import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/bakalari/timetable_change.dart';
import 'package:schoolarc/models/bakalari/timetable_lesson_model.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';

class TimetableTile extends StatelessWidget {
  const TimetableTile({
    super.key,
    required this.lesson,
    required this.columnWidth,
    required this.onTap,
    this.isHighlighted = false,
    this.leftTop = false,
    this.rightTop = false,
    this.leftBottom = false,
    this.rightBottom = false,
  });

  final TimeTableLesson? lesson;
  final double columnWidth;
  final bool isHighlighted;
  final bool leftTop;
  final bool rightTop;
  final bool leftBottom;
  final bool rightBottom;
  final void Function(TimeTableLesson? lesson)? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.col;
    Color tileColor = isHighlighted
        ? colorScheme.tertiaryContainer
        : colorScheme.surfaceContainer;
    final change = lesson?.change;
    if (change != null) {
      tileColor = Theme.of(context).colorScheme.errorContainer;
    }

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(leftBottom ? 16 : 4),
        bottomRight: Radius.circular(rightBottom ? 16 : 4),
        topLeft: Radius.circular(leftTop ? 16 : 4),
        topRight: Radius.circular(rightTop ? 16 : 4),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: columnWidth,
        height: double.infinity,
        decoration: BoxDecoration(
          border: lesson?.subject == null
              ? Border.all(
                  color: tileColor,
                  width: 2,
                )
              : null,
          color: lesson?.subject == null ? null : tileColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(leftBottom ? 16 : 4),
            bottomRight: Radius.circular(rightBottom ? 16 : 4),
            topLeft: Radius.circular(leftTop ? 16 : 4),
            topRight: Radius.circular(rightTop ? 16 : 4),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (onTap != null) {
                onTap!(lesson);
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (lesson?.subject?.id == '')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue.harmonizeWith(tileColor),
                          ),
                        ),
                      ],
                    ),
                  if (lesson?.subject?.isFromBakalari == true &&
                      settings.get(Setting.debugMode))
                    Text('baka: ${lesson?.subject?.bakaId}'),
                  const Spacer(),
                  if (lesson?.change?.type == ChangeType.canceled)
                    Text(
                      lesson?.change?.shortcut ?? '',
                      style: googleSansFlex(width: 120),
                    ),
                  if (lesson?.subject != null)
                    Text(
                      lesson?.subject?.shortcut ?? '',
                      style: googleSansFlex(
                        size: 20,
                        weight: 700,
                        width: 130,
                        roundness: 100,
                        color: change != null
                            ? Theme.of(context).colorScheme.onErrorContainer
                            : null,
                      ),
                    ),
                  const Spacer(),
                  if (lesson?.teacher != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lesson?.teacher?.shortcut ?? '',
                          style: googleSansFlex(width: 50, size: 16),
                        ),
                        Text(
                          lesson?.room ?? '',
                          style: googleSansFlex(width: 50, size: 16),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
