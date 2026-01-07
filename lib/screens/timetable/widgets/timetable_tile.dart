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

  BorderRadiusGeometry getBorderRadius({double subtract = 0}) {
    return BorderRadius.only(
      bottomLeft: Radius.circular(leftBottom ? 16 - subtract : 4 - subtract),
      bottomRight: Radius.circular(rightBottom ? 16 - subtract : 4 - subtract),
      topLeft: Radius.circular(leftTop ? 16 - subtract : 4 - subtract),
      topRight: Radius.circular(rightTop ? 16 - subtract : 4 - subtract),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.col;
    final change = lesson?.change;
    Color backgroundCol = isHighlighted
        ? colorScheme.tertiaryContainer
        : colorScheme.surfaceContainer;
    Color foregroundCol = isHighlighted
        ? colorScheme.onTertiaryContainer
        : colorScheme.onSurface;
    if (change != null) {
      backgroundCol = context.col.errorContainer;
      foregroundCol = context.col.onErrorContainer;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: columnWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        border: lesson?.subject == null
            ? Border.all(color: backgroundCol, width: 2)
            : null,
        color: lesson?.subject == null ? null : backgroundCol,
        borderRadius: getBorderRadius(),
      ),
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: getBorderRadius(
          subtract: lesson?.subject == null ? 2 : 0,
        ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    lesson?.subject?.id == ''
                        ? Container(
                            height: 5,
                            width: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.blue.harmonizeWith(backgroundCol),
                            ),
                          )
                        : const SizedBox.square(dimension: 5),
                  ],
                ),
                if (lesson?.subject?.isFromBakalari == true &&
                    settings.get(Setting.debugMode))
                  Text('baka: ${lesson?.subject?.bakaId}'),
                const Spacer(flex: 10),
                if (lesson?.change?.type == ChangeType.canceled)
                  Text(
                    lesson?.change?.shortcut ?? '',
                    style: googleSansFlex(width: 120, color: foregroundCol),
                  ),
                Text(
                  lesson?.subject?.shortcut ?? '',
                  style: googleSansFlex(
                    size: 20,
                    weight: 700,
                    width: 130,
                    roundness: 100,
                    color: foregroundCol,
                  ),
                ),
                (lesson?.teacher != null || lesson?.room != null)
                    ? const Spacer(flex: 10)
                    : const Spacer(flex: 16),
                if (lesson?.teacher != null || lesson?.room != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lesson?.teacher?.shortcut ?? '',
                        style: googleSansFlex(
                          width: 50,
                          size: 16,
                          color: foregroundCol,
                        ),
                      ),
                      Text(
                        lesson?.room ?? '',
                        style: googleSansFlex(
                          width: 50,
                          size: 16,
                          color: foregroundCol,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
