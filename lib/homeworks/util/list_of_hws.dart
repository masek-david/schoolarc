import 'package:flutter/material.dart';
import 'package:school_manager/homeworks/data/hw_dto_model.dart';
import 'package:school_manager/homeworks/util/homework_tile.dart';

class ListOfHws extends StatefulWidget {
  const ListOfHws({
    super.key,
    required this.hwList,
    required this.priority,
    required this.textOfList,
    required this.changeCompletion,
    required this.deleteHw,
    required this.editHw,
  });

  final Function deleteHw;
  final Function editHw;
  final Function(int index) changeCompletion;

  final List<HomeworkDTO>? hwList;
  final int priority;
  final String textOfList;

  @override
  State<ListOfHws> createState() => _ListOfHwsState();
}

class _ListOfHwsState extends State<ListOfHws> {
  @override
  Widget build(BuildContext context) {
    Color tileBkgColor = ElevationOverlay.applySurfaceTint(
        Theme.of(context).colorScheme.surface,
        Theme.of(context).colorScheme.primary,
        0.8);
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
              title: Text('${widget.textOfList}${widget.priority.toString()}'),
              initiallyExpanded: true,
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
                      hwText: hw.text,
                      hwDeadline: hw.deadline,
                      hwSubject: hw.subject,
                      hwPriority: hw.priority,
                      hwCompletion: hw.completion,
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
