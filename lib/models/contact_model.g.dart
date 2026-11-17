// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactModelAdapter extends TypeAdapter<ContactModel> {
  @override
  final int typeId = 0;

  @override
  ContactModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactModel(
      id: fields[0] as String,
      displayName: fields[1] as String,
      displayNumber: fields[2] as String,
      realNumber: fields[3] as String,
      imagePath: fields[4] as String?,
      notes: fields[5] as String?,
      tags: (fields[6] as List?)?.cast<String>() ?? [],
      category: fields[7] as String?,
      isFavorite: fields[8] as bool? ?? false,
      isHidden: fields[9] as bool? ?? false,
      isPinned: fields[10] as bool? ?? false,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ContactModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.displayNumber)
      ..writeByte(3)
      ..write(obj.realNumber)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.isHidden)
      ..writeByte(10)
      ..write(obj.isPinned)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
