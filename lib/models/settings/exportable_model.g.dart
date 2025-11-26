// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exportable_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExportableModelAdapter extends TypeAdapter<ExportableModel> {
  @override
  final int typeId = 12;

  @override
  ExportableModel read(BinaryReader reader) {
    return ExportableModel();
  }

  @override
  void write(BinaryWriter writer, ExportableModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.mainImage)
      ..writeByte(4)
      ..write(obj.additionalImages)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.lastEdited);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportableModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
