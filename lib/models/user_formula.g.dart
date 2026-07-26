// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_formula.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserFormulaAdapter extends TypeAdapter<UserFormula> {
  @override
  final int typeId = 2;

  @override
  UserFormula read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserFormula(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as String,
      formula: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserFormula obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.formula);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFormulaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
