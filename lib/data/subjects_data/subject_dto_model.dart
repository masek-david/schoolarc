import 'package:school_manager/data/subjects_data/subject_model.dart';

class SubjectDTO {
  SubjectDTO({
    required this.name,
    required this.shortcut,
    required this.dbIndex,
  });

  String name;
  String shortcut;
  int dbIndex;

  Subject convert(){
    return Subject(name: name, shortcut: shortcut);
  }
}
