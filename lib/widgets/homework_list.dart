import 'package:flutter/material.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/data/priority_model.dart';
import 'package:school_manager/widgets/animated_completion.dart';

class HomeworkList extends StatelessWidget {
  const HomeworkList({
    super.key,
    required this.hwList,
    required this.changeCompletion,
    required this.deleteHw,
    required this.editHw,
    required this.updateListView,
    this.showText = false,
    this.showDates = true,
    this.textFull = 'Homeworks',
    this.textEmpty,
  });

  final List<HomeworkDTO> hwList;
  final Function(int dbIndex, bool value) changeCompletion;
  final Function(int dbIndex) deleteHw;
  final Function(int dbIndex) editHw;
  final Function() updateListView;
  final bool showText;
  final bool showDates;
  final String textFull;
  final String? textEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hwList.isEmpty && showText)
          TextSeparator(
            text: textEmpty ?? 'No $textFull',
            greydOut: true,
          )
        else if (showText)
          TextSeparator(text: textFull),
        ...List.generate(hwList.length, (index) {
          HomeworkDTO hw = hwList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: AnimatedCompletionTile(
              hw: hw,
              showDate: showDates,
              priority: Priority(hw.priority, context),
              onChangedCompletion: (value) =>
                  changeCompletion(hw.dbIndex, value),
              onDelete: () => deleteHw(hw.dbIndex),
              onEdit: () => editHw(hw.dbIndex),
              onAnimationEnd: updateListView,
            ),
          );
        }),
      ],
    );
  }
}
