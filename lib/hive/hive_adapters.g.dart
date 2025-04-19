// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class TimeTableAdapter extends TypeAdapter<TimeTableEntity> {
  @override
  final int typeId = 3;

  @override
  TimeTableEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeTableEntity(
      (fields[0] as List).cast<LessonTimes>(),
    )..table =
        (fields[1] as List).map((e) => (e as List).cast<String?>()).toList();
  }

  @override
  void write(BinaryWriter writer, TimeTableEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lessonTimes)
      ..writeByte(1)
      ..write(obj.table);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HomeworkAdapter extends TypeAdapter<HomeworkEntity> {
  @override
  final int typeId = 4;

  @override
  HomeworkEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HomeworkEntity(
      text: fields[1] as String,
      description: fields[2] as String?,
      subjectId: fields[3] as String?,
      deadline: fields[4] as DateTime,
      priority: (fields[5] as num).toInt(),
      order: (fields[6] as num).toInt(),
      isCompleted: fields[7] as bool,
      isDeleted: fields[8] as bool,
      timestamp: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HomeworkEntity obj) {
    writer
      ..writeByte(9)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.subjectId)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.order)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.isDeleted)
      ..writeByte(9)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeworkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExamAdapter extends TypeAdapter<ExamEntity> {
  @override
  final int typeId = 5;

  @override
  ExamEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamEntity(
      isDeleted: fields[7] as bool,
      subjectId: fields[1] as String?,
      text: fields[2] as String,
      description: fields[5] as String?,
      date: fields[3] as DateTime,
      priority: (fields[4] as num).toInt(),
      timestamp: fields[6] as DateTime,
      order: (fields[8] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ExamEntity obj) {
    writer
      ..writeByte(8)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.isDeleted)
      ..writeByte(8)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LogAdapter extends TypeAdapter<Log> {
  @override
  final int typeId = 6;

  @override
  Log read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Log(
      log: fields[0] as String,
      date: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Log obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.log)
      ..writeByte(1)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubjectAdapter extends TypeAdapter<SubjectEntity> {
  @override
  final int typeId = 7;

  @override
  SubjectEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectEntity(
      timestamp: fields[4] as DateTime,
      isDeleted: fields[5] as bool,
      name: fields[0] as String,
      shortcut: fields[1] as String,
      bakaId: fields[2] as String?,
      order: (fields[6] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, SubjectEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.shortcut)
      ..writeByte(2)
      ..write(obj.bakaId)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.isDeleted)
      ..writeByte(6)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonTimesAdapter extends TypeAdapter<LessonTimes> {
  @override
  final int typeId = 8;

  @override
  LessonTimes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LessonTimes(
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      name: fields[0] == null ? '' : fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LessonTimes obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonTimesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
