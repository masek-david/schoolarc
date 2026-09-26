enum LessonChangeType {
  canceled,
  added,
  removed,
  roomChanged,
  substitution,
  other,
}

class LessonChange {
  LessonChange({
    required this.type,
    required this.description,
    this.name,
    this.shortcut,
  });

  LessonChangeType type;
  String description;
  String? shortcut;
  String? name;
}
