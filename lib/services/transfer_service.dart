import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/jajanan.dart';
import '../models/transaction.dart' as model;

class TransferService {
  // Generate JSON data untuk transfer dengan kompresi
  static String generateTransferData({
    required List<Jajanan> products,
    required List<model.Transaction> transactions,
  }) {
    // Buat data seminimal mungkin
    final data = {
      'v': '1', // version disingkat
      't': DateTime.now().millisecondsSinceEpoch, // timestamp as int
      'p': products.map((p) => _compressProduct(p)).toList(),
      'tx': transactions.map((t) => _compressTransaction(t)).toList(),
    };

    final jsonString = jsonEncode(data);

    // Compress dengan gzip untuk data lebih kecil
    final compressed = gzip.encode(utf8.encode(jsonString));

    // Convert ke base64 untuk QR Code
    return base64Encode(compressed);
  }

  // Compress product data (field names disingkat)
  static Map<String, dynamic> _compressProduct(Jajanan product) {
    return {
      'i': product.id,
      'n': product.nama,
      'k': product.kategori,
      'hb': product.hargaBeli,
      'hj': product.hargaJual,
      's': product.stok,
      'img': product.fotoPath,
    };
  }

  // Compress transaction data
  static Map<String, dynamic> _compressTransaction(model.Transaction tx) {
    return {
      'i': tx.id,
      'ci': tx.customerId,
      'cn': tx.customerName,
      'it': tx.items
          .map(
            (item) => {
              'ji': item.jajananId,
              'n': item.nama,
              'q': item.qty,
              'hb': item.hargaBeli,
              'hj': item.hargaJual,
            },
          )
          .toList(),
      'thb': tx.totalHargaBeli,
      'thj': tx.totalHargaJual,
      'tl': tx.totalLaba,
      'd': tx.transactionDate.millisecondsSinceEpoch,
    };
  }

  // Parse JSON data dari QR Code
  static Map<String, dynamic>? parseTransferData(String qrData) {
    try {
      // Decode base64
      final compressed = base64Decode(qrData);

      // Decompress gzip
      final decompressed = gzip.decode(compressed);

      // Parse JSON
      final jsonString = utf8.decode(decompressed);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validasi struktur
      if (!data.containsKey('v') ||
          !data.containsKey('p') ||
          !data.containsKey('tx')) {
        return null;
      }

      return data;
    } catch (e) {
      debugPrint('Error parsing transfer data: $e');
      return null;
    }
  }

  // Extract products dari transfer data
  static List<Jajanan> extractProducts(Map<String, dynamic> data) {
    try {
      final productsList = data['p'] as List;
      return productsList
          .map((p) => _decompressProduct(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error extracting products: $e');
      return [];
    }
  }

  // Decompress product data
  static Jajanan _decompressProduct(Map<String, dynamic> data) {
    return Jajanan(
      id: data['i'] as String,
      nama: data['n'] as String,
      kategori: data['k'] as String,
      hargaBeli: (data['hb'] as num).toDouble(),
      hargaJual: (data['hj'] as num).toDouble(),
      stok: data['s'] as int,
      fotoPath: data['img'] as String?,
    );
  }

  // Extract transactions dari transfer data
  static List<model.Transaction> extractTransactions(
    Map<String, dynamic> data,
  ) {
    try {
      final transactionsList = data['tx'] as List;
      return transactionsList
          .map((t) => _decompressTransaction(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error extracting transactions: $e');
      return [];
    }
  }

  // Decompress transaction data
  static model.Transaction _decompressTransaction(Map<String, dynamic> data) {
    final items = (data['it'] as List).map((item) {
      return model.TransactionItem(
        jajananId: item['ji'] as String,
        nama: item['n'] as String,
        qty: item['q'] as int,
        hargaBeli: (item['hb'] as num).toDouble(),
        hargaJual: (item['hj'] as num).toDouble(),
      );
    }).toList();

    return model.Transaction(
      id: data['i'] as String,
      customerId: data['ci'] as String,
      customerName: data['cn'] as String,
      items: items,
      totalHargaBeli: (data['thb'] as num).toDouble(),
      totalHargaJual: (data['thj'] as num).toDouble(),
      totalLaba: (data['tl'] as num).toDouble(),
      transactionDate: DateTime.fromMillisecondsSinceEpoch(data['d'] as int),
    );
  }

  // Split data jika terlalu besar untuk 1 QR Code
  static List<String> splitLargeData(String data, {int maxChunkSize = 2000}) {
    if (data.length <= maxChunkSize) {
      return [data];
    }

    final chunks = <String>[];
    final totalChunks = (data.length / maxChunkSize).ceil();

    for (int i = 0; i < totalChunks; i++) {
      final start = i * maxChunkSize;
      final end = (start + maxChunkSize > data.length)
          ? data.length
          : start + maxChunkSize;
      final chunk = data.substring(start, end);

      // Add metadata untuk chunked data
      final chunkData = {'chunk': i + 1, 'total': totalChunks, 'data': chunk};

      chunks.add(jsonEncode(chunkData));
    }

    return chunks;
  }

  // Combine chunks
  static String? combineChunks(List<String> chunks) {
    try {
      final buffer = StringBuffer();
      final sortedChunks = <Map<String, dynamic>>[];

      for (final chunk in chunks) {
        sortedChunks.add(jsonDecode(chunk) as Map<String, dynamic>);
      }

      sortedChunks.sort(
        (a, b) => (a['chunk'] as int).compareTo(b['chunk'] as int),
      );

      for (final chunk in sortedChunks) {
        buffer.write(chunk['data']);
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('Error combining chunks: $e');
      return null;
    }
  }
}
