// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'football_field.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FootballFieldAdapter extends TypeAdapter<FootballField> {
  @override
  final int typeId = 0;

  @override
  FootballField read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FootballField(
      city: fields[0] as String,
      district: fields[1] as String,
      fieldName: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, FootballField obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.city)
      ..writeByte(1)
      ..write(obj.district)
      ..writeByte(2)
      ..write(obj.fieldName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FootballFieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
