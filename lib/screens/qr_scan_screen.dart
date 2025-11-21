import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/jajanan_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/transfer_service.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  final List<String> _scannedChunks = [];
  int _expectedChunks = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || _isProcessing) return;
    
    final String? qrData = barcodes.first.rawValue;
    if (qrData == null || qrData.isEmpty) return;
    if (_isProcessing || qrData.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // Cek apakah ini chunked data
      Map<String, dynamic>? chunkInfo;
      try {
        final decoded = TransferService.parseTransferData(qrData);
        if (decoded != null && decoded.containsKey('chunk')) {
          chunkInfo = decoded;
        } else {
          chunkInfo = null;
        }
      } catch (e) {
        chunkInfo = null;
      }

      if (chunkInfo != null) {
        // Chunked data
        final chunkNum = chunkInfo['chunk'] as int;
        final totalChunks = chunkInfo['total'] as int;

        if (_expectedChunks == 0) {
          _expectedChunks = totalChunks;
        }

        if (!_scannedChunks.contains(qrData)) {
          _scannedChunks.add(qrData);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'QR $chunkNum/$totalChunks ✓ - ${_scannedChunks.length < totalChunks ? "Scan QR berikutnya" : "Lengkap!"}',
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          // Delay sebentar agar user bisa ganti ke QR berikutnya
          await Future.delayed(const Duration(milliseconds: 1500));
        }

        if (_scannedChunks.length >= _expectedChunks) {
          // Semua chunk sudah di-scan
          final combinedData = TransferService.combineChunks(_scannedChunks);
          if (combinedData != null) {
            await _importData(combinedData);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gagal menggabungkan data'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        }
      } else {
        // Single QR code
        await _importData(qrData);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _importData(String qrData) async {
    final data = TransferService.parseTransferData(qrData);

    if (data == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code tidak valid'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final products = TransferService.extractProducts(data);
    final transactions = TransferService.extractTransactions(data);

    if (products.isEmpty && transactions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada data yang dapat diimport'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    if (mounted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Data'),
          content: Text(
            'Ditemukan:\n'
            '• ${products.length} produk\n'
            '• ${transactions.length} transaksi\n\n'
            'Data akan ditambahkan ke database lokal. Lanjutkan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        setState(() => _isProcessing = false);
        return;
      }

      // Import data
      final jajananProvider = context.read<JajananProvider>();
      final transactionProvider = context.read<TransactionProvider>();

      int importedProducts = 0;
      int importedTransactions = 0;

      for (final product in products) {
        await jajananProvider.addItem(product);
        importedProducts++;
      }

      for (final transaction in transactions) {
        await transactionProvider.addTransaction(transaction);
        importedTransactions++;
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Berhasil import $importedProducts produk dan $importedTransactions transaksi',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanArea = size.width * 0.7; // 70% dari lebar layar

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Custom overlay dengan scan area persegi
          CustomPaint(
            painter: ScannerOverlay(scanArea: scanArea),
            child: SizedBox(width: size.width, height: size.height),
          ),
          // Info text
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.black.withOpacity(0.7),
              child: Column(
                children: [
                  const Text(
                    'Posisikan QR Code di dalam kotak',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_expectedChunks > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_scannedChunks.length} dari $_expectedChunks QR Code ter-scan',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  if (_isProcessing) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(color: Colors.white),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter untuk overlay scanner
class ScannerOverlay extends CustomPainter {
  final double scanArea;

  ScannerOverlay({required this.scanArea});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2 - 50),
            width: scanArea,
            height: scanArea,
          ),
          const Radius.circular(12),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, cutoutPath),
      backgroundPaint,
    );

    // Draw corner brackets
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final cornerLength = scanArea * 0.15;
    final left = (size.width - scanArea) / 2;
    final top = (size.height - scanArea) / 2 - 50;
    final right = left + scanArea;
    final bottom = top + scanArea;

    // Top-left
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + cornerLength),
      borderPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(right, top),
      Offset(right - cornerLength, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(right, top),
      Offset(right, top + cornerLength),
      borderPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + cornerLength, bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left, bottom - cornerLength),
      borderPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right - cornerLength, bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
