import 'package:flutter/material.dart';
import 'package:school_manager/homeworks/data/hw_dto_model.dart';
import 'package:school_manager/homeworks/util/homework_tile.dart';
import 'package:school_manager/util/priority_model.dart';

class ListOfHws extends StatefulWidget {
  const ListOfHws({
    super.key,
    required this.hwList,
    this.priorityOfList,
    required this.changeCompletion,
    required this.context,
    required this.deleteHw,
    required this.editHw,
  });

  final Function deleteHw;
  final Function editHw;
  final Function(int index) changeCompletion;

  final BuildContext context;
  final List<HomeworkDTO>? hwList;
  final Priority? priorityOfList;

  @override
  State<ListOfHws> createState() => _ListOfHwsState();
}

class _ListOfHwsState extends State<ListOfHws> {
  @override
  Widget build(BuildContext context) {
    String titleText = 'Completed';
    Color titleTextColor = Colors.white;
    Color? tileBkgColor;
    bool initiallyExpanded = false;

    titleTextColor = Theme.of(widget.context).colorScheme.inverseSurface;

    if (widget.priorityOfList != null) {
      titleText = widget.priorityOfList!.name;
      titleTextColor = widget.priorityOfList!.color;
      initiallyExpanded = true;
      tileBkgColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
    }

    if (widget.hwList!.isEmpty) {
      return const SizedBox();
    }    
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: tileBkgColor,
      ),
      child: Column(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              listTileTheme: ListTileTheme.of(context).copyWith(
                dense: true,
                visualDensity: VisualDensity.compact,
              ),
            ),
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    titleText,
                    style: TextStyle(
                      color: titleTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    height: 25,
                    width: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSecondary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      widget.hwList!.length.toString(),
                    ),
                  ),
                ],
              ),
              initiallyExpanded: initiallyExpanded,
              shape: const Border(),
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.hwList?.length,
                  itemBuilder: (context, indexInSortedList) {
                    if (widget.hwList == null && widget.hwList!.isEmpty) {
                      return null;
                    }
                    HomeworkDTO hw = widget.hwList![indexInSortedList];
                    return HomeworkTile(
                      text: hw.text,
                      deadline: hw.deadline,
                      subject: hw.subject,
                      priority: Priority(hw.priority, context),
                      completion: hw.completion,
                      onDelete: (context) => widget.deleteHw(hw.index),
                      onEdit: () => widget.editHw(hw.index),
                      onChangedCompletion: (p0) =>
                          widget.changeCompletion(hw.index),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
