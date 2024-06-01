class HomeworkDTO{
  HomeworkDTO({required this.subject, required this.text, required this.deadline, required this.completion, required this.priority, required this.index});
  
  String subject;
  String text;
  DateTime deadline;
  bool completion;
  int priority;
  int index;
}