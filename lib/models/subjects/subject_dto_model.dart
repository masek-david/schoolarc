import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/utils/extensions/string_extension.dart';

class SubjectDTO {
  SubjectDTO({
    required this.name,
    required this.shortcut,
    required this.dbIndex,
    required this.bakaId,
    required this.fireId,
    required this.timestamp,
    required this.isDeleted,
    required this.order,
  });

  String name;
  String shortcut;
  int dbIndex;
  String? bakaId;
  String? fireId;
  Timestamp timestamp;
  bool isDeleted;
  int order;

  Subject convert() {
    return Subject(
      name: name,
      shortcut: shortcut,
      bakaId: bakaId,
      fireId: fireId,
      isDeleted: isDeleted,
      timestamp: timestamp.toDate(),
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

  bool get isFromBakalari {
    return bakaId != null && bakaId != '';
  }

  SubjectDTO copyWith({
    String? name,
    String? shortcut,
    int? dbIndex,
    bool? isDeleted,
    String? bakaId,
    String? fireId,
    Timestamp? timestamp,
    int? order,
  }) {
    return SubjectDTO(
      name: name ?? this.name,
      shortcut: shortcut ?? this.shortcut,
      dbIndex: dbIndex ?? this.dbIndex,
      isDeleted: isDeleted ?? this.isDeleted,
      bakaId: bakaId ?? this.bakaId,
      fireId: fireId ?? this.fireId,
      timestamp: timestamp ?? this.timestamp,
      order: order ?? this.order,
    );
  }
}
