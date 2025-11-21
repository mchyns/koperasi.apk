import 'package:hive/hive.dart';

part 'cart_item.g.dart';

@HiveType(typeId: 4)
class CartItem extends HiveObject {
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
  int maxStok; // untuk validasi

  @HiveField(6)
  String? fotoPath;

  CartItem({
    required this.jajananId,
    required this.nama,
    required this.hargaBeli,
    required this.hargaJual,
    required this.qty,
    required this.maxStok,
    this.fotoPath,
  });

  // Subtotal harga jual
  double get subtotal => hargaJual * qty;

  // Subtotal laba
  double get subtotalLaba => (hargaJual - hargaBeli) * qty;

  // Copy with
  CartItem copyWith({
    String? jajananId,
    String? nama,
    double? hargaBeli,
    double? hargaJual,
    int? qty,
    int? maxStok,
    String? fotoPath,
  }) {
    return CartItem(
      jajananId: jajananId ?? this.jajananId,
      nama: nama ?? this.nama,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      hargaJual: hargaJual ?? this.hargaJual,
      qty: qty ?? this.qty,
      maxStok: maxStok ?? this.maxStok,
      fotoPath: fotoPath ?? this.fotoPath,
    );
  }

  // Increment qty (dengan validasi stok)
  bool incrementQty() {
    if (qty < maxStok) {
      qty++;
      return true;
    }
    return false;
  }

  // Decrement qty
  bool decrementQty() {
    if (qty > 1) {
      qty--;
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return 'CartItem(nama: $nama, qty: $qty, subtotal: $subtotal)';
  }
}
