import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/homeworks/data/hw_service.dart';
import 'package:school_manager/homeworks/util/list_of_hws.dart';
import 'package:school_manager/homeworks/util/hw_bottom_sheet.dart';
import 'package:school_manager/homeworks/data/hw_dto_model.dart';

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

  // deletes hw and shows snackbar to undo it
  void deleteHw(int index) {
    setState(() {
      HomeworkDTO deletedHw = service.getHomework(index);
      service.deleteHw(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Homework deleted'),
            action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  setState(() {
                    service.saveNewHW(
                        date: deletedHw.deadline,
                        priority: deletedHw.priority,
                        subject: deletedHw.subject,
                        text: deletedHw.text);
                    sortedHw = service.sortHwList();
                  });
                })),
      );
      sortedHw = service.sortHwList();
    });
  }

  void changeCompletion(int index) {
    setState(() {
      service.changeCompletion(index);
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
          index: 0, // index neni potreba u zakladani noveho listu
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
                // index: index,
                subject: subject,
                text: text,
              );
              sortedHw = service.sortHwList();
              Navigator.of(context).pop();
            });
          },
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

  void editHw(int index) {
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
      appBar: AppBar(
        title: const Text('Homeworks'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNewHW();
          HapticFeedback.lightImpact();
        },
        enableFeedback: true,
        child: const Icon(Icons.add),
      ),
      body: SlidableAutoCloseBehavior(
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            final priorityIndex = 4 - 1 - index; // obrati index
            if (index == 4) {
              return const SizedBox(height: 70);
            }
            return ListOfHws(
                hwList: sortedHw[priorityIndex],
                priority: priorityIndex,
                changeCompletion: changeCompletion,
                deleteHw: deleteHw,
                editHw: editHw);
          },
        ),
      ),
    );
  }
}
