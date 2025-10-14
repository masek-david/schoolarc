import 'package:schoolarc/models/subjects/subject_entity_model.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class Subject {
  Subject({
    required this.name,
    required this.shortcut,
    required this.id,
    required this.bakaId,
    required this.timestamp,
    required this.isDeleted,
    required this.order,
  });

  final String name;
  final String shortcut;
  final String id;
  final String? bakaId;
  final DateTime timestamp;
  final bool isDeleted;
  final double order;

  SubjectEntity convert() {
    return SubjectEntity(
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
    return '$name, $shortcut, bakaId: $bakaId, order: $order, timestamp: $timestamp, ${isDeleted ? '[deleted]' : ''}';
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
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'],
      id: json['id'],
      shortcut: json['shortcut'],
      bakaId: json['bakaId'],
      order: json['order'],
      isDeleted: json['isDeleted'],
      timestamp: DateTime.tryParse(json['timestamp']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFireJson() {
    return {
      'n': name,
      's': shortcut,
      if (bakaId != null) 'b': bakaId,
      if (order != 0) 'o': order,
      if (isDeleted) 'del': isDeleted,
      't': timestamp.millisecondsSinceEpoch,
    };
  }

  Subject.fromFireJson(Map<String, dynamic> json)
      : name = json['n'],
        id = json['id'],
        shortcut = json['s'],
        bakaId = json['b'],
        order = json['o'] ?? 0,
        isDeleted = json['del'] ?? false,
        timestamp = DateTime.fromMillisecondsSinceEpoch(json['t']);

  bool get isFromBakalari {
    return bakaId != null && bakaId != '';
  }

  Subject copyWith({
    String? name,
    String? shortcut,
    String? id,
    bool? isDeleted,
    Object? bakaId = noChange,
    DateTime? timestamp,
    double? order,
  }) {
    return Subject(
      name: name ?? this.name,
      shortcut: shortcut ?? this.shortcut,
      id: id ?? this.id,
      isDeleted: isDeleted ?? this.isDeleted,
      bakaId: bakaId == noChange ? this.bakaId : bakaId as String?,
      timestamp: timestamp ?? this.timestamp,
      order: order ?? this.order,
    );
  }
}
