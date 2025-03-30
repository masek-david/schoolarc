import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';

part 'subject_model.g.dart';

@HiveType(typeId: 2)
class Subject extends HiveObject {
  Subject({
    required this.fireId,
    required DateTime? timestamp,
    required this.isDeleted,
    required this.name,
    required this.shortcut,
    required this.bakaId,
    required this.order,
  }) : timestamp = timestamp ?? DateTime.now() {
    if (timestamp == null) {
      saveSafe();
    }
  }

  @HiveField(0)
  final String name;
  @HiveField(1)
  final String shortcut;
  @HiveField(2)
  final String? bakaId;
  @HiveField(3)
  final String? fireId;
  @HiveField(4)
  final DateTime timestamp;
  @HiveField(5, defaultValue: false)
  final bool isDeleted;
  @HiveField(6, defaultValue: 0)
  final int order;

  /// saves this as it is now to hive
  void saveSafe() async {
    // i dont know why it works, this box doesnt need to exist, maybe its just the delay?
    await Hive.openBox('subjects');

    if (isInBox) {
      save();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shortcut': shortcut,
      'bakaId': bakaId,
      'id': fireId,
      'order': order,
      'isDeleted': isDeleted,
    };
  }

  Subject.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        shortcut = json['shortcut'],
        bakaId = json['bakaId'],
        fireId = json['id'],
        order = json['order'],
        isDeleted = json['isDeleted'],
        timestamp = DateTime.now();

  SubjectDTO convertToDTO(int dbIndex) {
    return SubjectDTO(
      name: name,
      shortcut: shortcut,
      dbIndex: dbIndex,
      bakaId: bakaId,
      isDeleted: isDeleted == true,
      fireId: fireId,
      timestamp: Timestamp.fromDate(timestamp),
      order: order,
    );
  }

  Subject copyWith({
    String? name,
    String? shortcut,
    int? dbIndex,
    bool? isDeleted,
    String? bakaId,
    String? fireId,
    DateTime? timestamp,
    int? order,
  }) {
    return Subject(
      name: name ?? this.name,
      shortcut: shortcut ?? this.shortcut,
      isDeleted: isDeleted ?? this.isDeleted,
      bakaId: bakaId ?? this.bakaId,
      fireId: fireId ?? this.fireId,
      timestamp: timestamp ?? this.timestamp,
      order: order ?? this.order,
    );
  }
}
