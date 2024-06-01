import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/exams/data/exam_service.dart';
import 'package:school_manager/exams/data/exam_dto_model.dart';
import 'package:school_manager/exams/util/exam_list.dart';
import 'package:school_manager/exams/util/exam_bottom_sheet.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  ServiceExam service = ServiceExam();
  Map<int, List<ExamDTO>> sortedExam = {
    0: <ExamDTO>[],
    1: <ExamDTO>[],
    2: <ExamDTO>[],
    3: <ExamDTO>[],
  };

  @override
  void initState() {
    service.initiate();

    sortedExam = service.sortExamList();
    super.initState();
  }

  // text controller
  var _subjectController = TextEditingController();
  var _nameController = TextEditingController();

  // deletes exam and shows snackbar to undo it
  void deleteExam(int index) {
    setState(() {
      ExamDTO deletedExam = service.getExam(index);
      service.deleteExam(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Homework deleted'),
            action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  setState(() {
                    service.saveNewExam(
                        date: deletedExam.date,
                        priority: deletedExam.priority,
                        subject: deletedExam.subject,
                        text: deletedExam.text);
                    sortedExam = service.sortExamList();
                  });
                })),
      );
      sortedExam = service.sortExamList();
    });
  }

  void createNewExam() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return ExamBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: DateTime.now(),
          initialPriority: 0,
          index: 0, // index neni potreba u zakladani noveho listu
          onSave: ({
            required context,
            required date,
            required index,
            required priority,
            required subject,
            required text,
          }) {
            setState(() {
              service.saveNewExam(
                date: date,
                priority: priority,
                // index: index,
                subject: subject,
                text: text,
              );
              sortedExam = service.sortExamList();
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

  void editExam(int index) {
    ExamDTO currentlyEditedTask = service.getExam(index);
    _nameController = TextEditingController(text: currentlyEditedTask.text);
    _subjectController =
        TextEditingController(text: currentlyEditedTask.subject);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return ExamBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: currentlyEditedTask.date,
          initialPriority: currentlyEditedTask.priority,
          index: index,
          onSave: (
              {required context,
              required date,
              required index,
              required priority,
              required subject,
              required text}) {
            setState(() {
              service.saveEditedExam(
                date: date,
                priority: priority,
                index: index,
                subject: subject,
                text: text,
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
        title: const Text('Exams'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNewExam();
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
            return ListOfExams(
                examList: sortedExam[priorityIndex],
                priority: priorityIndex,
                deleteExam: deleteExam,
                editExam: editExam);
          },
        ),
      ),
    );
  }
}
