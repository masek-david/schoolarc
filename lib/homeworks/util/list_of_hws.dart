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
  final Function changeCompletion;

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
    Color titleTextColor = Theme.of(widget.context).colorScheme.inverseSurface;;
    Color? tileBkgColor;
    bool initiallyExpanded = false;

    if (widget.priorityOfList != null) {
      titleText = widget.priorityOfList!.name;
      titleTextColor = widget.priorityOfList!.color;
      initiallyExpanded = true;
      tileBkgColor = Theme.of(context).colorScheme.primary.withAlpha(20);
    }

    if (widget.hwList!.isEmpty) {
      return const SizedBox();
    }    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: ListTileTheme.of(context).copyWith(
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        ),
        child: ExpansionTile(
          collapsedBackgroundColor: tileBkgColor,
          initiallyExpanded: initiallyExpanded,
          shape: const Border(),
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
              // indicator of number of hw
              Container(
                height: 22,
                width: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  widget.hwList!.length.toString(),
                ),
              ),
            ],
          ),
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.hwList?.length,
              itemBuilder: (context, indexInSortedList) {
                if (widget.hwList == null && widget.hwList!.isEmpty) {
                  return null;
                }
      
                // sets padding only between the tiles, not top or bottom
                EdgeInsetsGeometry padding = const EdgeInsets.only(top: 10);
                if (indexInSortedList == 0){
                  padding = EdgeInsets.zero;
                }
                
                HomeworkDTO hw = widget.hwList![indexInSortedList];
                return Padding(
                  padding: padding,
                  child: HomeworkTile(
                    text: hw.text,
                    deadline: hw.deadline,
                    subject: hw.subject,
                    priority: Priority(hw.priority, context),
                    completion: hw.completion,
                    onDelete: (context) => widget.deleteHw(hw.index),
                    onEdit: () => widget.editHw(hw.index),
                    onChangedCompletion: (completion) =>
                        widget.changeCompletion(hw.index),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
