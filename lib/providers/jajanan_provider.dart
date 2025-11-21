import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/jajanan.dart';
import '../constants/app_constants.dart';

class JajananProvider extends ChangeNotifier {
  late Box<Jajanan> _box;
  List<Jajanan> _items = [];
  bool _isLoading = false;

  List<Jajanan> get items => _items;
  List<Jajanan> get allJajanan => _items;
  bool get isLoading => _isLoading;

  // Get items with stock > 0
  List<Jajanan> get availableItems =>
      _items.where((item) => item.stok > 0).toList();

  // Get items with stock == 0
  List<Jajanan> get outOfStockItems =>
      _items.where((item) => item.isHabis).toList();

  // Get unique categories
  List<String> get categories {
    final cats = _items.map((item) => item.kategori).toSet().toList();
    cats.sort();
    return cats;
  }

  JajananProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box<Jajanan>(AppConstants.hiveBoxJajanan);
    await loadItems();
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    _items = _box.values.toList();
    _items.sort((a, b) => a.nama.compareTo(b.nama));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(Jajanan jajanan) async {
    await _box.put(jajanan.id, jajanan);
    await loadItems();
  }

  Future<void> updateItem(Jajanan jajanan) async {
    await _box.put(jajanan.id, jajanan);
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
    await loadItems();
  }

  Jajanan? getItemById(String id) {
    return _box.get(id);
  }

  // Update stok setelah transaksi
  Future<void> updateStok(String id, int newStok) async {
    final item = _box.get(id);
    if (item != null) {
      final updated = item.copyWith(stok: newStok);
      await _box.put(id, updated);
      await loadItems();
    }
  }

  // Reduce stock (for checkout)
  Future<bool> reduceStock(String id, int qty) async {
    final item = _box.get(id);
    if (item != null && item.stok >= qty) {
      final newStok = item.stok - qty;
      await updateStok(id, newStok);
      return true;
    }
    return false;
  }

  // Update from Firestore (called by sync provider)
  Future<void> updateFromFirestore(Jajanan jajanan) async {
    await _box.put(jajanan.id, jajanan);
    await loadItems();
  }

  // Delete from Firestore (called by sync provider)
  Future<void> deleteFromFirestore(String id) async {
    await _box.delete(id);
    await loadItems();
  }
}
