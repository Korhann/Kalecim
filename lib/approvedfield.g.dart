// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approvedfield.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApprovedFieldAdapter extends TypeAdapter<ApprovedField> {
  @override
  final int typeId = 1;

  @override
  ApprovedField read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApprovedField(
      fields: (fields[0] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ApprovedField obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.fields);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApprovedFieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
