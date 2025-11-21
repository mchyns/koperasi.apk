// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 2;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      customerId: fields[1] as String,
      customerName: fields[2] as String,
      items: (fields[3] as List).cast<TransactionItem>(),
      totalHargaBeli: fields[4] as double,
      totalHargaJual: fields[5] as double,
      totalLaba: fields[6] as double,
      transactionDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.totalHargaBeli)
      ..writeByte(5)
      ..write(obj.totalHargaJual)
      ..writeByte(6)
      ..write(obj.totalLaba)
      ..writeByte(7)
      ..write(obj.transactionDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionItemAdapter extends TypeAdapter<TransactionItem> {
  @override
  final int typeId = 3;

  @override
  TransactionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionItem(
      jajananId: fields[0] as String,
      nama: fields[1] as String,
      hargaBeli: fields[2] as double,
      hargaJual: fields[3] as double,
      qty: fields[4] as int,
    )
      ..subtotalBeli = fields[5] as double
      ..subtotalJual = fields[6] as double
      ..subtotalLaba = fields[7] as double;
  }

  @override
  void write(BinaryWriter writer, TransactionItem obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.subtotalBeli)
      ..writeByte(6)
      ..write(obj.subtotalJual)
      ..writeByte(7)
      ..write(obj.subtotalLaba);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
