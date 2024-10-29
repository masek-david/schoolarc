// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeTableAdapter extends TypeAdapter<TimeTable> {
  @override
  final int typeId = 3;

  @override
  TimeTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeTable(
      (fields[0] as List).cast<LessonTimes>(),
    )..table = (fields[1] as List)
        .map((dynamic e) => (e as List).cast<int?>())
        .toList();
  }

  @override
  void write(BinaryWriter writer, TimeTable obj) {
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
