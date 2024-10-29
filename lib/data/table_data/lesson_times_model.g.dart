// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_times_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LessonTimesAdapter extends TypeAdapter<LessonTimes> {
  @override
  final int typeId = 4;

  @override
  LessonTimes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LessonTimes(
      name: fields[2] as String,
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LessonTimes obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj._startTime)
      ..writeByte(1)
      ..write(obj._endTime)
      ..writeByte(2)
      ..write(obj.name);
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
