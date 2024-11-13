import 'package:hive/hive.dart';
import 'package:school_manager/data/subjects_data/subject_dto_model.dart';

part 'subject_model.g.dart';

@HiveType(typeId: 2)
class Subject extends HiveObject {
  Subject({
    required this.name,
    required this.shortcut,
    this.bakaId,
  });

  @HiveField(0)
  final String name;
  @HiveField(1)
  final String shortcut;
  @HiveField(2)
  final String? bakaId;

  SubjectDTO convertToDTO(int dbIndex) {
    return SubjectDTO(
      name: name,
      shortcut: shortcut,
      dbIndex: dbIndex,
      bakaId: bakaId
    );
  }
}
