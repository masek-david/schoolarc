class ExamDTO {
  ExamDTO(
      {required this.subject,
      required this.text,
      required this.deadline,
      required this.priority,
      required this.dbIndex,
      required this.completion});

  String subject;
  String text;
  DateTime deadline;
  bool completion;
  int priority;
  int dbIndex;
}
