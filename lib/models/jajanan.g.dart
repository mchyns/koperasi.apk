// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jajanan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JajananAdapter extends TypeAdapter<Jajanan> {
  @override
  final int typeId = 0;

  @override
  Jajanan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Jajanan(
      id: fields[0] as String,
      nama: fields[1] as String,
      hargaBeli: fields[2] as double,
      hargaJual: fields[3] as double,
      stok: fields[4] as int,
      kategori: fields[5] as String,
      fotoPath: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Jajanan obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.hargaBeli)
      ..writeByte(3)
      ..write(obj.hargaJual)
      ..writeByte(4)
      ..write(obj.stok)
      ..writeByte(5)
      ..write(obj.kategori)
      ..writeByte(6)
      ..write(obj.fotoPath)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JajananAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
