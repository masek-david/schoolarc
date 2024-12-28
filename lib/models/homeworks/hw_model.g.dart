// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hw_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HomeworkAdapter extends TypeAdapter<Homework> {
  @override
  final int typeId = 0;

  @override
  Homework read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Homework(
      fireId: fields[6] as String?,
      isDeleted: fields[8] == null ? false : fields[8] as bool,
      subjectDbIndex: fields[0] as int?,
      text: fields[1] as String,
      deadline: fields[2] as DateTime,
      completion: fields[3] as bool,
      priority: fields[4] as int,
      description: fields[5] as String?,
      timestamp: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Homework obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.subjectDbIndex)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.deadline)
      ..writeByte(3)
      ..write(obj.completion)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.fireId)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.isDeleted);
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
