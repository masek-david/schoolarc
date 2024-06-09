class ExamDTO {
  ExamDTO(
      {required this.subject,
      required this.text,
      required this.date,
      required this.priority,
      required this.index,
      required this.isCompleted});

  String subject;
  String text;
  DateTime date;
  bool isCompleted;
  int priority;
  int index;
}
