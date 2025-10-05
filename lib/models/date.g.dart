// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DateAdapter extends TypeAdapter<Date> {
  @override
  final typeId = 100;

  @override
  Date read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Date(
      (fields[0] as num).toInt(),
      (fields[1] as num).toInt(),
      (fields[2] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Date obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.year)
      ..writeByte(1)
      ..write(obj.month)
      ..writeByte(2)
      ..write(obj.day);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
