// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhotoItemAdapter extends TypeAdapter<PhotoItem> {
  @override
  final int typeId = 1;

  @override
  PhotoItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhotoItem(
      fields[0] as String,
      fields[1] as String,
      fields[2] as int,
      fields[3] as int,
      fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PhotoItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.width)
      ..writeByte(3)
      ..write(obj.height)
      ..writeByte(4)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}