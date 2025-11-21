import 'package:hive/hive.dart';

part 'jajanan.g.dart';

@HiveType(typeId: 0)
class Jajanan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nama;

  @HiveField(2)
  double hargaBeli;

  @HiveField(3)
  double hargaJual;

  @HiveField(4)
  int stok;

  @HiveField(5)
  String kategori;

  @HiveField(6)
  String? fotoPath;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  Jajanan({
    required this.id,
    required this.nama,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
    required this.kategori,
    this.fotoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Menghitung laba per item
  double get labaPerItem => hargaJual - hargaBeli;

  // Menghitung persentase laba
  double get persentaseLaba =>
      hargaBeli > 0 ? (labaPerItem / hargaBeli) * 100 : 0;

  // Check apakah stok habis
  bool get isHabis => stok == 0;

  // Check apakah stok rendah
  bool get isStokRendah => stok > 0 && stok <= 10;

  // Copy with method untuk update
  Jajanan copyWith({
    String? id,
    String? nama,
    double? hargaBeli,
    double? hargaJual,
    int? stok,
    String? kategori,
    String? fotoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Jajanan(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      hargaJual: hargaJual ?? this.hargaJual,
      stok: stok ?? this.stok,
      kategori: kategori ?? this.kategori,
      fotoPath: fotoPath ?? this.fotoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // From Map
  factory Jajanan.fromMap(Map<String, dynamic> map) {
    return Jajanan(
      id: map['id'] as String,
      nama: map['nama'] as String,
      hargaBeli: (map['hargaBeli'] as num).toDouble(),
      hargaJual: (map['hargaJual'] as num).toDouble(),
      stok: map['stok'] as int,
      kategori: map['kategori'] as String,
      fotoPath: map['fotoPath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Jajanan(id: $id, nama: $nama, hargaJual: $hargaJual, stok: $stok)';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'hargaBeli': hargaBeli,
      'hargaJual': hargaJual,
      'stok': stok,
      'kategori': kategori,
      'fotoPath': fotoPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
