import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/homeworks/data/hw_dto_model.dart';
import 'package:school_manager/homeworks/util/list_of_hws.dart';
import 'package:school_manager/util/priority_model.dart';

class PriorityView extends StatefulWidget {
  const PriorityView({
    super.key,
    required this.hwByPriority,
    required this.completedHws,
    required this.changeCompletion,
    required this.createNewHw,
    required this.deleteHw,
    required this.editHw,
  });

  final Map<int, List<HomeworkDTO>> hwByPriority;
  final List<HomeworkDTO> completedHws;
  final Function changeCompletion;
  final Function createNewHw;
  final Function editHw;
  final Function deleteHw;

  @override
  State<PriorityView> createState() => _PriorityViewState();
}

class _PriorityViewState extends State<PriorityView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.createNewHw();
          HapticFeedback.lightImpact();
        },
        enableFeedback: true,
        child: const Icon(Icons.add),
      ),
      body: SlidableAutoCloseBehavior(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) {
              final priorityIndex = 4 - 1 - index; // obrati index
              if (index == 4) {
                return ListOfHws(
                  context: context,
                  hwList: widget.completedHws,
                  changeCompletion: widget.changeCompletion,
                  deleteHw: widget.deleteHw,
                  editHw: widget.editHw,
                );
              }
              if (index == 5) {
                return const SizedBox(height: 70);
              }
              return ListOfHws(
                context: context,
                hwList: widget.hwByPriority[priorityIndex],
                priorityOfList: Priority(priorityIndex, context),
                changeCompletion: widget.changeCompletion,
                deleteHw: widget.deleteHw,
                editHw: widget.editHw,
              );
            },
          ),
        ),
      ),
    );
  }
}
