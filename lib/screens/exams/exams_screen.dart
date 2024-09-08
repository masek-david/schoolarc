import 'package:flutter/material.dart';
import 'package:school_manager/data/exams_data/exam_service.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';
import 'package:school_manager/data/priority_model.dart';
import 'package:school_manager/screens/exams/widgets/exam_bottom_sheet.dart';
import 'package:school_manager/screens/exams/widgets/priority_view.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  ExamService service = ExamService();
  Map<int, List<ExamDTO>> examsByPriority = {
    0: <ExamDTO>[],
    1: <ExamDTO>[],
    2: <ExamDTO>[],
    3: <ExamDTO>[],
  };
  List<ExamDTO> completedExams = [];
  late List<Priority> priorities = List.generate(
    4,
    (index) => Priority(index, context),
  );

  Widget viewWidget = const Placeholder();

  // text controllers for creating and editing exams
  var _subjectController = TextEditingController();
  var _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    examsByPriority = service.sortByPriority();
    completedExams = service.getCompletedExams();
  }

  // deletes exam and shows snackbar to undo it
  void deleteExam(int dbIndex) {
    service.deleteExam(dbIndex);
    updateListView();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exam deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            service.revertLastlyDeletedExam();
            updateListView();
          },
        ),
      ),
    );
  }

  Future<void> createNewExam({DateTime? initialDate}) async {
    initialDate ??= DateTime.now();
    // pokud je initial date null, nastavi se na datetime.now

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return ExamBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: initialDate!,
          initialPriority: 0,
          index: 0, // index neni potreba u zakladani noveho testu
          onSave: ({
            required context,
            required date,
            required index,
            required priority,
            required subject,
            required text,
          }) async {
            await service.saveNewExam(
              date: date,
              priority: priority,
              subject: subject,
              text: text,
            );
            updateListView();
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

  void editExam(int dbIndex) {
    ExamDTO currentlyEditedTask = service.getExam(dbIndex);
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
          initialDate: currentlyEditedTask.deadline,
          initialPriority: currentlyEditedTask.priority,
          index: dbIndex,
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
                dbIndex: index,
                subject: subject,
                text: text,
              );
              updateListView();
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

  void reorderExam(
      int oldItemIndex, int oldPriority, int newItemIndex, int newPriority) {
    service.changeSequence(
        oldItemIndex, oldPriority, newItemIndex, newPriority);
    updateListView();
  }

  void updateListView() {
    if (mounted) {
      setState(() {
        examsByPriority = service.sortByPriority();
        completedExams = service.getCompletedExams();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PriorityView(
        examsByPriority: examsByPriority,
        completedExams: completedExams,
        priorities: priorities,
        createNewExam: createNewExam,
        deleteExam: deleteExam,
        editExam: editExam,
        reorderExam: reorderExam,
      ),
    );
  }
}
