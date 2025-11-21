import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/jajanan.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  // Total qty in cart
  int get totalQty => _items.fold(0, (sum, item) => sum + item.qty);

  // Total harga jual
  double get totalHargaJual => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  // Total harga beli (modal)
  double get totalHargaBeli =>
      _items.fold(0.0, (sum, item) => sum + (item.hargaBeli * item.qty));

  // Total laba
  double get totalLaba => _items.fold(0.0, (sum, item) => sum + item.subtotalLaba);

  // Add item to cart
  void addItem(Jajanan jajanan) {
    final existingIndex = _items.indexWhere((item) => item.jajananId == jajanan.id);

    if (existingIndex >= 0) {
      // Item already in cart, increment qty if stock allows
      if (_items[existingIndex].incrementQty()) {
        notifyListeners();
      }
    } else {
      // New item, add to cart
      final cartItem = CartItem(
        jajananId: jajanan.id,
        nama: jajanan.nama,
        hargaBeli: jajanan.hargaBeli,
        hargaJual: jajanan.hargaJual,
        qty: 1,
        maxStok: jajanan.stok,
        fotoPath: jajanan.fotoPath,
      );
      _items.add(cartItem);
      notifyListeners();
    }
  }

  // Update item qty
  void updateItemQty(String jajananId, int newQty) {
    final index = _items.indexWhere((item) => item.jajananId == jajananId);
    if (index >= 0) {
      if (newQty <= 0) {
        removeItem(jajananId);
      } else if (newQty <= _items[index].maxStok) {
        _items[index] = _items[index].copyWith(qty: newQty);
        notifyListeners();
      }
    }
  }

  // Increment item qty
  void incrementItem(String jajananId) {
    final index = _items.indexWhere((item) => item.jajananId == jajananId);
    if (index >= 0) {
      if (_items[index].incrementQty()) {
        notifyListeners();
      }
    }
  }

  // Decrement item qty
  void decrementItem(String jajananId) {
    final index = _items.indexWhere((item) => item.jajananId == jajananId);
    if (index >= 0) {
      if (_items[index].decrementQty()) {
        notifyListeners();
      } else {
        // If qty becomes 0, remove item
        removeItem(jajananId);
      }
    }
  }

  // Remove item from cart
  void removeItem(String jajananId) {
    _items.removeWhere((item) => item.jajananId == jajananId);
    notifyListeners();
  }

  // Clear cart
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Check if item is in cart
  bool containsItem(String jajananId) {
    return _items.any((item) => item.jajananId == jajananId);
  }

  // Get item qty in cart
  int getItemQty(String jajananId) {
    final item = _items.firstWhere(
      (item) => item.jajananId == jajananId,
      orElse: () => CartItem(
        jajananId: '',
        nama: '',
        hargaBeli: 0,
        hargaJual: 0,
        qty: 0,
        maxStok: 0,
      ),
    );
    return item.qty;
  }
}
