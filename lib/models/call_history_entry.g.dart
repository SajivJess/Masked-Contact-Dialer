// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallHistoryEntryAdapter extends TypeAdapter<CallHistoryEntry> {
  @override
  final int typeId = 1;

  @override
  CallHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallHistoryEntry(
      id: fields[0] as String,
      contactId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      callMode: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CallHistoryEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contactId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.callMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
