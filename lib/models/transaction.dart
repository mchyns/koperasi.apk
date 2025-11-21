import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerId;

  @HiveField(2)
  String customerName;

  @HiveField(3)
  List<TransactionItem> items;

  @HiveField(4)
  double totalHargaBeli; // Total modal

  @HiveField(5)
  double totalHargaJual; // Total penjualan

  @HiveField(6)
  double totalLaba; // Total laba

  @HiveField(7)
  DateTime transactionDate;

  Transaction({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.totalHargaBeli,
    required this.totalHargaJual,
    required this.totalLaba,
    DateTime? transactionDate,
  }) : transactionDate = transactionDate ?? DateTime.now();

  // Hitung persentase laba
  double get persentaseLaba =>
      totalHargaBeli > 0 ? ((totalLaba / totalHargaBeli) * 100) : 0;

  // Total qty items
  int get totalQty => items.fold(0, (sum, item) => sum + item.qty);

  // Copy with
  Transaction copyWith({
    String? id,
    String? customerId,
    String? customerName,
    List<TransactionItem>? items,
    double? totalHargaBeli,
    double? totalHargaJual,
    double? totalLaba,
    DateTime? transactionDate,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      totalHargaBeli: totalHargaBeli ?? this.totalHargaBeli,
      totalHargaJual: totalHargaJual ?? this.totalHargaJual,
      totalLaba: totalLaba ?? this.totalLaba,
      transactionDate: transactionDate ?? this.transactionDate,
    );
  }

  // To Map untuk export
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalHargaBeli': totalHargaBeli,
      'totalHargaJual': totalHargaJual,
      'totalLaba': totalLaba,
      'persentaseLaba': persentaseLaba,
      'totalQty': totalQty,
      'transactionDate': transactionDate.toIso8601String(),
    };
  }

  // From Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      items: (map['items'] as List)
          .map((item) => TransactionItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalHargaBeli: (map['totalHargaBeli'] as num).toDouble(),
      totalHargaJual: (map['totalHargaJual'] as num).toDouble(),
      totalLaba: (map['totalLaba'] as num).toDouble(),
      transactionDate: DateTime.parse(map['transactionDate'] as String),
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, customerName: $customerName, totalLaba: $totalLaba)';
  }
}

@HiveType(typeId: 3)
class TransactionItem extends HiveObject {
  @HiveField(0)
  String jajananId;

  @HiveField(1)
  String nama;

  @HiveField(2)
  double hargaBeli;

  @HiveField(3)
  double hargaJual;

  @HiveField(4)
  int qty;

  @HiveField(5)
  double subtotalBeli; // hargaBeli * qty

  @HiveField(6)
  double subtotalJual; // hargaJual * qty

  @HiveField(7)
  double subtotalLaba; // (hargaJual - hargaBeli) * qty

  TransactionItem({
    required this.jajananId,
    required this.nama,
    required this.hargaBeli,
    required this.hargaJual,
    required this.qty,
  })  : subtotalBeli = hargaBeli * qty,
        subtotalJual = hargaJual * qty,
        subtotalLaba = (hargaJual - hargaBeli) * qty;

  // Copy with
  TransactionItem copyWith({
    String? jajananId,
    String? nama,
    double? hargaBeli,
    double? hargaJual,
    int? qty,
  }) {
    return TransactionItem(
      jajananId: jajananId ?? this.jajananId,
      nama: nama ?? this.nama,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      hargaJual: hargaJual ?? this.hargaJual,
      qty: qty ?? this.qty,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'jajananId': jajananId,
      'nama': nama,
      'hargaBeli': hargaBeli,
      'hargaJual': hargaJual,
      'qty': qty,
      'subtotalBeli': subtotalBeli,
      'subtotalJual': subtotalJual,
      'subtotalLaba': subtotalLaba,
    };
  }

  // From Map
  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      jajananId: map['jajananId'] as String,
      nama: map['nama'] as String,
      hargaBeli: (map['hargaBeli'] as num).toDouble(),
      hargaJual: (map['hargaJual'] as num).toDouble(),
      qty: map['qty'] as int,
    );
  }

  @override
  String toString() {
    return 'TransactionItem(nama: $nama, qty: $qty, subtotalLaba: $subtotalLaba)';
  }
}
