import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 1)
class Customer extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nama;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime lastTransactionAt;

  @HiveField(4)
  int totalTransactions;

  @HiveField(5)
  double totalSpent;

  Customer({
    required this.id,
    required this.nama,
    DateTime? createdAt,
    DateTime? lastTransactionAt,
    this.totalTransactions = 0,
    this.totalSpent = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastTransactionAt = lastTransactionAt ?? DateTime.now();

  // Update stats setelah transaksi
  void updateAfterTransaction(double amount) {
    totalTransactions++;
    totalSpent += amount;
    lastTransactionAt = DateTime.now();
  }

  // Copy with
  Customer copyWith({
    String? id,
    String? nama,
    DateTime? createdAt,
    DateTime? lastTransactionAt,
    int? totalTransactions,
    double? totalSpent,
  }) {
    return Customer(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      createdAt: createdAt ?? this.createdAt,
      lastTransactionAt: lastTransactionAt ?? this.lastTransactionAt,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'createdAt': createdAt.toIso8601String(),
      'lastTransactionAt': lastTransactionAt.toIso8601String(),
      'totalTransactions': totalTransactions,
      'totalSpent': totalSpent,
    };
  }

  // From Map
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      nama: map['nama'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastTransactionAt: DateTime.parse(map['lastTransactionAt'] as String),
      totalTransactions: map['totalTransactions'] as int,
      totalSpent: (map['totalSpent'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, nama: $nama, totalTransactions: $totalTransactions)';
  }
}
