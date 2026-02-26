enum ChangeType {
  canceled,
  added,
  removed,
  roomChanged,
  substitution,
}

ChangeType getChangeType(String changeType) {
  switch (changeType) {
    case 'Canceled':
      return ChangeType.canceled;
    case 'Added':
      return ChangeType.added;
    case 'Removed':
      return ChangeType.removed;
    case 'RoomChanged':
      return ChangeType.roomChanged;
    case 'Substitution':
      return ChangeType.substitution;
  }

  throw 'Not a valid changetype: $changeType';
}

class BakaChange {
  BakaChange({
    required this.type,
    required this.description,
    this.name,
    this.shortcut,
  });

  ChangeType type;
  String description;
  String? shortcut;
  String? name;
}
