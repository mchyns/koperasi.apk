import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants/app_colors.dart';
import '../providers/jajanan_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/transfer_service.dart';

class QRShareScreen extends StatefulWidget {
  const QRShareScreen({super.key});

  @override
  State<QRShareScreen> createState() => _QRShareScreenState();
}

class _QRShareScreenState extends State<QRShareScreen> {
  String? _qrData;
  List<String>? _qrChunks;
  int _currentChunkIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateQRData();
  }

  Future<void> _generateQRData() async {
    setState(() => _isLoading = true);

    final jajananProvider = context.read<JajananProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    final products = jajananProvider.allJajanan;
    final transactions = transactionProvider.allTransactions;

    if (products.isEmpty && transactions.isEmpty) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada data untuk dibagikan'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    final data = TransferService.generateTransferData(
      products: products,
      transactions: transactions,
    );

    // SELALU split untuk QR code yang lebih simple dan mudah di-scan
    // Max 800 bytes per QR untuk QR yang gampang dibaca
    final chunks = TransferService.splitLargeData(data, maxChunkSize: 800);

    setState(() {
      _qrChunks = chunks;
      _qrData = chunks[0];
      _isLoading = false;
    });
  }

  void _nextChunk() {
    if (_qrChunks != null && _currentChunkIndex < _qrChunks!.length - 1) {
      setState(() {
        _currentChunkIndex++;
        _qrData = _qrChunks![_currentChunkIndex];
      });
    }
  }

  void _previousChunk() {
    if (_currentChunkIndex > 0) {
      setState(() {
        _currentChunkIndex--;
        _qrData = _qrChunks![_currentChunkIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bagikan Data via QR'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _qrData == null
          ? const Center(child: Text('Gagal generate QR Code'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.qr_code_2,
                          size: 48,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan QR Code ini di device lain',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Consumer2<JajananProvider, TransactionProvider>(
                          builder: (context, jajanan, transaction, _) {
                            return Text(
                              '${jajanan.allJajanan.length} produk • ${transaction.allTransactions.length} transaksi',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: _qrData!,
                      version: QrVersions.auto,
                      size: 280,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel
                          .L, // Low error correction = lebih simple
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Chunk navigation - SELALU tampilkan
                  if (_qrChunks != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'QR ${_currentChunkIndex + 1} dari ${_qrChunks!.length}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                          if (_qrChunks!.length > 1) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Scan semua QR Code secara berurutan',
                              style: TextStyle(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_qrChunks!.length > 1) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _currentChunkIndex > 0
                                ? _previousChunk
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            label: const Text('Sebelumnya'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed:
                                _currentChunkIndex < _qrChunks!.length - 1
                                ? _nextChunk
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            label: const Text('Selanjutnya'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],

                  const SizedBox(height: 24),
                  const Text(
                    'Pastikan device penerima sudah membuka Scanner QR',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
