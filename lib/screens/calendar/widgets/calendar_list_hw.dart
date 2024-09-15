import 'package:flutter/material.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/data/priority_model.dart';
import 'package:school_manager/widgets/animated_completion.dart';

class CalendarListHw extends StatelessWidget {
  const CalendarListHw({
    super.key,
    required this.hwList,
    required this.changeCompletion,
    required this.deleteHw,
    required this.editHw,
    required this.updateListView,
  });

  final List<HomeworkDTO> hwList;
  final Function(int dbIndex, bool value) changeCompletion;
  final Function(int dbIndex) deleteHw;
  final Function(int dbIndex) editHw;
  final Function() updateListView;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(hwList.length + 1, (index) {
        if (hwList.isEmpty) {
          return const TextSeparator(
            text: 'No Homeworks',
            greydOut: true,
          );
        }

        if (index == 0) {
          return const TextSeparator(text: 'Homeworks');
        }

        HomeworkDTO hw = hwList[index - 1];
        return Padding(
          padding: const EdgeInsets.all(5),
          child: AnimatedCompletionTile(
            hw: hw,
            showDate: false,
            priority: Priority(hw.priority, context),
            onChangedCompletion: (value) => changeCompletion(hw.dbIndex, value),
            onDelete: () => deleteHw(hw.dbIndex),
            onEdit: () => editHw(hw.dbIndex),
            onAnimationEnd: updateListView,
          ),
        );
      }),
    );
  }
}
