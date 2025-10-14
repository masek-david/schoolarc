// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class LogAdapter extends TypeAdapter<Log> {
  @override
  final typeId = 6;

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

class LessonTimesAdapter extends TypeAdapter<LessonTimes> {
  @override
  final typeId = 8;

  @override
  LessonTimes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LessonTimes(
      startTime: fields[1] as TimeOfDay,
      endTime: fields[2] as TimeOfDay,
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

class HomeworkEntityAdapter extends TypeAdapter<HomeworkEntity> {
  @override
  final typeId = 9;

  @override
  HomeworkEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Manual date migration code beginning
    final date = fields[3];
    Date finalDate;
    if (date is DateTime) {
      finalDate = Date.fromDateTime(date.toLocal());
    } else {
      finalDate = date as Date;
    }
    // Manual date migration code end

    return HomeworkEntity(
      text: fields[0] as String,
      description: fields[1] == null ? '' : fields[1] as String,
      subjectId: fields[2] as String?,
      date: finalDate,
      priority: (fields[4] as num).toInt(),
      order: (fields[5] as num).toDouble(),
      isCompleted: fields[6] as bool,
      isDeleted: fields[7] as bool,
      timestamp: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HomeworkEntity obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.subjectId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.order)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.isDeleted)
      ..writeByte(8)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeworkEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExamEntityAdapter extends TypeAdapter<ExamEntity> {
  @override
  final typeId = 10;

  @override
  ExamEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Manual date migration code beginning
    final date = fields[2];
    Date finalDate;
    if (date is DateTime) {
      finalDate = Date.fromDateTime(date.toLocal());
    } else {
      finalDate = date as Date;
    }
    // Manual date migration code end

    return ExamEntity(
      isDeleted: fields[6] as bool,
      subjectId: fields[0] as String?,
      text: fields[1] as String,
      description: fields[4] == null ? '' : fields[4] as String,
      date: finalDate,
      priority: (fields[3] as num).toInt(),
      timestamp: fields[5] as DateTime,
      order: (fields[7] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, ExamEntity obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.subjectId)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.priority)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.isDeleted)
      ..writeByte(7)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubjectEntityAdapter extends TypeAdapter<SubjectEntity> {
  @override
  final typeId = 11;

  @override
  SubjectEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectEntity(
      timestamp: fields[3] as DateTime,
      isDeleted: fields[4] as bool,
      name: fields[0] as String,
      shortcut: fields[1] as String,
      bakaId: fields[2] as String?,
      order: (fields[5] as num).toDouble(),
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
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.isDeleted)
      ..writeByte(5)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimeTableEntityAdapter extends TypeAdapter<TimeTableEntity> {
  @override
  final typeId = 12;

  @override
  TimeTableEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeTableEntity(
      (fields[0] as List?)?.cast<LessonTimes>(),
      (fields[1] as List?)?.map((e) => (e as List).cast<String?>()).toList(),
    );
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
      other is TimeTableEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
