class ExamDTO{
  ExamDTO({required this.subject, required this.text, required this.date, required this.priority, required this.index});
  
  String subject;
  String text;
  DateTime date;
  int priority;
  int index;
}