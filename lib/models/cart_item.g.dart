// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 4;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItem(
      jajananId: fields[0] as String,
      nama: fields[1] as String,
      hargaBeli: fields[2] as double,
      hargaJual: fields[3] as double,
      qty: fields[4] as int,
      maxStok: fields[5] as int,
      fotoPath: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.jajananId)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.hargaBeli)
      ..writeByte(3)
      ..write(obj.hargaJual)
      ..writeByte(4)
      ..write(obj.qty)
      ..writeByte(5)
      ..write(obj.maxStok)
      ..writeByte(6)
      ..write(obj.fotoPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
