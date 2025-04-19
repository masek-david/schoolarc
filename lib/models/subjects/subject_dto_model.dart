
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/utils/extensions/string_extension.dart';

class SubjectDTO {
  SubjectDTO({
    required this.name,
    required this.shortcut,
    required this.id,
    required this.bakaId,
    required this.timestamp,
    required this.isDeleted,
    required this.order,
  });

  String name;
  String shortcut;
  String id;
  String? bakaId;
  DateTime timestamp;
  bool isDeleted;
  int order;

  Subject convert() {
    return Subject(
      name: name,
      shortcut: shortcut,
      bakaId: bakaId,
      isDeleted: isDeleted,
      timestamp: timestamp,
      order: order,
    );
  }

  String get trimmedShortcut {
    return shortcut.trim();
  }

  @override
  String toString() {
    return '$name, $shortcut, bakaId: $bakaId, order: $order, timestamp: $timestamp';
  }

  bool containsText(String text) {
    return name.withoutDiacriticalMarks.toLowerCase().contains(
              text.withoutDiacriticalMarks.toLowerCase(),
            ) ||
        shortcut.withoutDiacriticalMarks.toLowerCase().contains(
              text.withoutDiacriticalMarks.toLowerCase(),
            );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shortcut': shortcut,
      'bakaId': bakaId,
      'id': id,
      'order': order,
      'isDeleted': isDeleted,
    };
  }

  SubjectDTO.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        id = json['id'],
        shortcut = json['shortcut'],
        bakaId = json['bakaId'],
        order = json['order'],
        isDeleted = json['isDeleted'],
        timestamp = DateTime.now().toUtc();

  Map<String, dynamic> toFireJson() {
    return {
      'n': name,
      's': shortcut,
      'b': bakaId,
      'o': order,
      'd': isDeleted,
      't': timestamp.toIso8601String(),
    };
  }

  SubjectDTO.fromFireJson(Map<String, dynamic>  json)
      : name = json['n'],
        id = json['id'],
        shortcut = json['s'],
        bakaId = json['b'],
        order = json['o'],
        isDeleted = json['d'],
        timestamp = DateTime.parse(json['t']);

  bool get isFromBakalari {
    return bakaId != null && bakaId != '';
  }

  SubjectDTO copyWith({
    String? name,
    String? shortcut,
    String? id,
    bool? isDeleted,
    String? bakaId,
    DateTime? timestamp,
    int? order,
  }) {
    return SubjectDTO(
      name: name ?? this.name,
      shortcut: shortcut ?? this.shortcut,
      id: id ?? this.id,
      isDeleted: isDeleted ?? this.isDeleted,
      bakaId: bakaId ?? this.bakaId,
      timestamp: timestamp ?? this.timestamp,
      order: order ?? this.order,
    );
  }
}
