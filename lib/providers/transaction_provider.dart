import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../constants/app_constants.dart';

class TransactionProvider extends ChangeNotifier {
  late Box<Transaction> _box;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  List<Transaction> get allTransactions => _transactions;
  bool get isLoading => _isLoading;

  TransactionProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box<Transaction>(AppConstants.hiveBoxTransactions);
    await loadTransactions();

    // Auto-cleanup data lebih dari 2 tahun (opsional, bisa diaktifkan)
    // await _autoCleanupOldData();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    _transactions = _box.values.toList();
    _transactions.sort(
      (a, b) => b.transactionDate.compareTo(a.transactionDate),
    );

    _isLoading = false;
    notifyListeners();
  }

  // Auto cleanup data lebih dari X tahun (untuk mencegah database membengkak)
  Future<int> autoCleanupOldData({int maxYears = 2}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: maxYears * 365));
    final oldTransactions = _transactions
        .where((t) => t.transactionDate.isBefore(cutoffDate))
        .toList();

    for (var transaction in oldTransactions) {
      await _box.delete(transaction.id);
    }

    if (oldTransactions.isNotEmpty) {
      await loadTransactions();
    }

    return oldTransactions.length;
  }

  // Kompaksi database untuk optimasi storage
  Future<void> compactDatabase() async {
    await _box.compact();
  }

  // Get database stats
  Map<String, dynamic> getDatabaseStats() {
    final totalTransactions = _box.length;
    final oldestTransaction = _transactions.isNotEmpty
        ? _transactions.last.transactionDate
        : null;
    final newestTransaction = _transactions.isNotEmpty
        ? _transactions.first.transactionDate
        : null;

    return {
      'totalTransactions': totalTransactions,
      'oldestDate': oldestTransaction,
      'newestDate': newestTransaction,
      'estimatedSizeKB': (totalTransactions * 0.5).toStringAsFixed(
        1,
      ), // ~500 bytes per transaction
    };
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    await loadTransactions();
  }

  // Get transactions for today
  List<Transaction> getTransactionsToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _transactions.where((t) {
      final transDate = DateTime(
        t.transactionDate.year,
        t.transactionDate.month,
        t.transactionDate.day,
      );
      return transDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Get transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return t.transactionDate.isAfter(
            start.subtract(const Duration(days: 1)),
          ) &&
          t.transactionDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Calculate total sales for today
  double getTotalSalesToday() {
    return getTransactionsToday().fold(0.0, (sum, t) => sum + t.totalHargaJual);
  }

  // Calculate total profit for today
  double getTotalProfitToday() {
    return getTransactionsToday().fold(0.0, (sum, t) => sum + t.totalLaba);
  }

  // Calculate profit percentage for today
  double getProfitPercentageToday() {
    final transactions = getTransactionsToday();
    if (transactions.isEmpty) return 0.0;

    final totalCost = transactions.fold(
      0.0,
      (sum, t) => sum + t.totalHargaBeli,
    );
    final totalProfit = transactions.fold(0.0, (sum, t) => sum + t.totalLaba);

    return totalCost > 0 ? (totalProfit / totalCost) * 100 : 0.0;
  }

  // Get statistics for date range
  Map<String, double> getStatsByDateRange(DateTime start, DateTime end) {
    final trans = getTransactionsByDateRange(start, end);
    final totalSales = trans.fold(0.0, (sum, t) => sum + t.totalHargaJual);
    final totalCost = trans.fold(0.0, (sum, t) => sum + t.totalHargaBeli);
    final totalProfit = trans.fold(0.0, (sum, t) => sum + t.totalLaba);

    return {
      'totalSales': totalSales,
      'totalCost': totalCost,
      'totalProfit': totalProfit,
      'profitPercentage': totalCost > 0 ? (totalProfit / totalCost) * 100 : 0.0,
    };
  }

  // Update from Firestore (called by sync provider)
  Future<void> updateFromFirestore(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    await loadTransactions();
  }

  // Delete from Firestore (called by sync provider)
  Future<void> deleteFromFirestore(String id) async {
    await _box.delete(id);
    await loadTransactions();
  }
}
