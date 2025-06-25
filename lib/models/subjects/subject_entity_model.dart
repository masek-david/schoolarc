
import 'package:hive_ce/hive.dart';
import 'package:school_manager/models/subjects/subject_model.dart';

class SubjectEntity extends HiveObject {
  SubjectEntity({
    required this.timestamp,
    required this.isDeleted,
    required this.name,
    required this.shortcut,
    required this.bakaId,
    required this.order,
  });

  final String name;
  final String shortcut;
  final String? bakaId;
  final DateTime timestamp;
  final bool isDeleted;
  final int order;

  Subject convert(String id) {
    return Subject(
      id: id,
      name: name,
      shortcut: shortcut,
      bakaId: bakaId,
      isDeleted: isDeleted == true,
      timestamp: timestamp,
      order: order,
    );
  }

  SubjectEntity copyWith({
    String? name,
    String? shortcut,
    bool? isDeleted,
    String? bakaId,
    DateTime? timestamp,
    int? order,
  }) {
    return SubjectEntity(
      name: name ?? this.name,
      shortcut: shortcut ?? this.shortcut,
      isDeleted: isDeleted ?? this.isDeleted,
      bakaId: bakaId ?? this.bakaId,
      timestamp: timestamp ?? this.timestamp,
      order: order ?? this.order,
    );
  }
}
