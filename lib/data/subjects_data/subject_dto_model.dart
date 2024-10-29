import 'package:school_manager/data/subjects_data/subject_model.dart';
import 'package:school_manager/extensions/string_extension.dart';

class SubjectDTO {
  SubjectDTO({
    required this.name,
    required this.shortcut,
    required this.dbIndex,
  });

  String name;
  String shortcut;
  int dbIndex;

  Subject convert() {
    return Subject(name: name, shortcut: shortcut);
  }

  String get trimmedShortcut {
    return shortcut.trim();
  }

  bool containsText(String text) {
    return name.withoutDiacriticalMarks.toLowerCase().contains(
              text.withoutDiacriticalMarks.toLowerCase(),
            ) ||
        shortcut.withoutDiacriticalMarks.toLowerCase().contains(
              text.withoutDiacriticalMarks.toLowerCase(),
            );
  }
}
