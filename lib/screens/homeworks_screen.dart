import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/data/service_hw.dart';
import 'package:school_manager/util/homework_tile.dart';
import 'package:school_manager/util/hw_create_bottom_sheet.dart';
import 'package:school_manager/data/hw_dto_model.dart';

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen> {
  ServiceHW service = ServiceHW();
  Map<int, List<HomeworkDTO>> sortedHw = {
    0: <HomeworkDTO>[],
    1: <HomeworkDTO>[],
    2: <HomeworkDTO>[],
    3: <HomeworkDTO>[],
  };

  @override
  void initState() {
    service.initiate();

    sortedHw = service.sortHwList();
    super.initState();
  }

  // text controller
  var _subjectController = TextEditingController();
  var _nameController = TextEditingController();

  void deleteTask(int index) {
    setState(() {
      service.deleteHw(index);
      sortedHw = service.sortHwList();
    });
  }

  void createNewHW() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return HwBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: DateTime.now(),
          initialPriority: 0,
          initialCompletion: false,
          onSave: ({
            required context,
            required date,
            required index,
            required priority,
            required subject,
            required completion,
            required text,
          }) {
            setState(() {
              service.saveNewHW(
                date: date,
                priority: priority,
                index: index,
                subject: subject,
                text: text,
              );
              Navigator.of(context).pop();
            });
          },
          index: 0, // index neni potreba u zakladani noveho listu
        );
      },
    ).then(
      // po zavreni bottomSheetu se smaze uzivatelem zadany text
      (value) => {
        _nameController.clear(),
        _subjectController.clear(),
      },
    );
  }

  void editHW(int index) {
    HomeworkDTO currentlyEditedTask = service.getHomework(index);
    _nameController = TextEditingController(text: currentlyEditedTask.text);
    _subjectController =
        TextEditingController(text: currentlyEditedTask.subject);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return HwBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: currentlyEditedTask.deadline,
          initialPriority: currentlyEditedTask.priority,
          initialCompletion: currentlyEditedTask.completion,
          index: index,
          onSave: (
              {required context,
              required date,
              required index,
              required priority,
              required subject,
              required completion,
              required text}) {
            setState(() {
              service.saveEditedHW(
                date: date,
                priority: priority,
                index: index,
                subject: subject,
                text: text,
                completion: completion,
              );
              Navigator.of(context).pop();
            });
          },
        );
      },
    ).then(
      (value) => {
        _nameController.clear(),
        _subjectController.clear(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHW,
        child: const Icon(Icons.add),
      ),
      body: SlidableAutoCloseBehavior(
        child: ListView.builder(
          itemCount: 4,
          itemBuilder: (context, index) {
            final priorityIndex = 4 - 1 - index; // obrati index
            return Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ElevationOverlay.applySurfaceTint(
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.primary,
                    0.8),
              ),
              child: Column(
                children: [
                  Padding(
                    // padding: EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Priority:'),
                        Text(priorityIndex.toString()),
                      ],
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: sortedHw[priorityIndex]!.length,
                    itemBuilder: (context, indexInSortedList) {
                      if (sortedHw[priorityIndex] != null &&
                          sortedHw[priorityIndex]!.isEmpty) {
                        return null;
                      }
                      HomeworkDTO hw =
                          sortedHw[priorityIndex]![indexInSortedList];
                      return HomeworkTile(
                        hwText: hw.text,
                        hwDeadline: hw.deadline,
                        hwSubject: hw.subject,
                        hwCompletion: hw.completion,
                        hwPriority: hw.priority,
                        onChangedCompletion: (value) {
                          setState(() {
                            service.changeCompletion(hw.index);
                          });
                        },
                        onDelete: (context) => deleteTask(hw.index),
                        onEdit: () => editHW(hw.index),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
