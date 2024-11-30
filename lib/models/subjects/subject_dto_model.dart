import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/utils/extensions/string_extension.dart';

class SubjectDTO {
  SubjectDTO({
    required this.name,
    required this.shortcut,
    required this.dbIndex,
    this.bakaId,
  });

  String name;
  String shortcut;
  int dbIndex;
  String? bakaId;

  Subject convert() {
    return Subject(
      name: name,
      shortcut: shortcut,
      bakaId: bakaId,
    );
  }

  String get trimmedShortcut {
    return shortcut.trim();
  }

  @override
  String toString() {
    return '$name, $shortcut, $bakaId';
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
