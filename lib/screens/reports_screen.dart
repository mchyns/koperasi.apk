import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? _selectedDateRange;
  bool _isGenerating = false;
  String? _selectedBuyer; // Filter berdasarkan nama pembeli

  @override
  void initState() {
    super.initState();
    // Default: Bulan ini
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isGenerating ? null : _generateAndShareExcel,
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateRangeSelector(),
          _buildBuyerFilter(),
          Expanded(child: _buildReportContent()),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Periode Laporan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildQuickFilterChip('Hari Ini', _setToday)),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickFilterChip('Minggu Ini', _setThisWeek),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickFilterChip('Bulan Ini', _setThisMonth),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDateRange,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDateRange != null
                          ? '${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDateRange!.end)}'
                          : 'Pilih Tanggal',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.surfaceLight,
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  Widget _buildBuyerFilter() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        // Get all unique buyer names from transactions
        final allTransactions = provider.getTransactionsByDateRange(
          _selectedDateRange!.start,
          _selectedDateRange!.end,
        );

        final buyerNames =
            allTransactions
                .where((t) => t.customerName.isNotEmpty)
                .map((t) => t.customerName)
                .toSet()
                .toList()
              ..sort();

        if (buyerNames.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.textLight, width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.person,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Filter Pembeli:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedBuyer,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Semua Pembeli'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Semua Pembeli'),
                    ),
                    ...buyerNames.map((name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedBuyer = value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportContent() {
    if (_selectedDateRange == null) {
      return const Center(child: Text('Pilih periode laporan'));
    }

    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        var transactions = provider.getTransactionsByDateRange(
          _selectedDateRange!.start,
          _selectedDateRange!.end,
        );

        // Filter by buyer name if selected
        if (_selectedBuyer != null && _selectedBuyer!.isNotEmpty) {
          transactions = transactions
              .where((t) => t.customerName == _selectedBuyer)
              .toList();
        }

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: AppColors.textLight.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada transaksi',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.textLight),
                ),
                const SizedBox(height: 8),
                Text(
                  'pada periode yang dipilih',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textLight),
                ),
              ],
            ),
          );
        }

        // Calculate totals
        double totalSales = 0;
        double totalCost = 0;
        double totalProfit = 0;
        int totalItems = 0;

        for (final transaction in transactions) {
          totalSales += transaction.totalHargaJual;
          totalCost += transaction.totalHargaBeli;
          totalProfit += transaction.totalLaba;
          totalItems += transaction.items.length;
        }

        final profitPercentage = totalCost > 0
            ? (totalProfit / totalCost) * 100
            : 0.0;

        return ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            _buildSummaryCard(
              transactions.length,
              totalSales,
              totalCost,
              totalProfit,
              profitPercentage,
              totalItems,
            ),
            const SizedBox(height: 24),
            Text(
              'Detail Transaksi (${transactions.length})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...transactions.map(
              (transaction) => _buildTransactionCard(transaction),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    int transactionCount,
    double totalSales,
    double totalCost,
    double totalProfit,
    double profitPercentage,
    int totalItems,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: AppColors.textOnPrimary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Ringkasan Laporan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            'Total Transaksi',
            '$transactionCount transaksi',
            Icons.receipt_outlined,
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow(
            'Total Item Terjual',
            '$totalItems item',
            Icons.shopping_cart_outlined,
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow(
            'Total Penjualan',
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp',
              decimalDigits: 0,
            ).format(totalSales),
            Icons.attach_money,
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow(
            'Total Modal',
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp',
              decimalDigits: 0,
            ).format(totalCost),
            Icons.money_off,
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow(
            'Total Laba Bersih',
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp',
              decimalDigits: 0,
            ).format(totalProfit),
            Icons.trending_up,
            isHighlight: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.percent,
                  color: AppColors.textOnPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Margin Keuntungan: ${profitPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.9),
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            fontSize: isHighlight ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: const Icon(Icons.receipt, color: AppColors.primary),
        ),
        title: Text(
          transaction.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat(
            'dd MMM yyyy, HH:mm',
            'id_ID',
          ).format(transaction.transactionDate),
          style: const TextStyle(color: AppColors.textLight),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp',
                decimalDigits: 0,
              ).format(transaction.totalHargaJual),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Laba: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(transaction.totalLaba)}',
              style: const TextStyle(fontSize: 12, color: AppColors.success),
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item yang dibeli:',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...transaction.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.nama} (${item.qty}x)',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp',
                            decimalDigits: 0,
                          ).format(item.hargaJual * item.qty),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Modal:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp',
                            decimalDigits: 0,
                          ).format(transaction.totalHargaBeli),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Margin:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          '${transaction.persentaseLaba.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDateRange = DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    });
  }

  void _setThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    setState(() {
      _selectedDateRange = DateTimeRange(
        start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    });
  }

  void _setThisMonth() {
    final now = DateTime.now();
    setState(() {
      _selectedDateRange = DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      );
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();

    // Adjust selected date range if it's in the future
    DateTimeRange? initialRange = _selectedDateRange;
    if (initialRange != null && initialRange.end.isAfter(now)) {
      initialRange = DateTimeRange(
        start: initialRange.start.isAfter(now) ? now : initialRange.start,
        end: now,
      );
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initialRange,
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = DateTimeRange(
          start: DateTime(
            picked.start.year,
            picked.start.month,
            picked.start.day,
          ),
          end: DateTime(
            picked.end.year,
            picked.end.month,
            picked.end.day,
            23,
            59,
            59,
          ),
        );
      });
    }
  }

  Future<void> _generateAndShareExcel() async {
    if (_selectedDateRange == null) return;

    setState(() => _isGenerating = true);

    try {
      final provider = context.read<TransactionProvider>();
      var transactions = provider.getTransactionsByDateRange(
        _selectedDateRange!.start,
        _selectedDateRange!.end,
      );

      // Filter by buyer name if selected
      if (_selectedBuyer != null && _selectedBuyer!.isNotEmpty) {
        transactions = transactions
            .where((t) => t.customerName == _selectedBuyer)
            .toList();
      }

      if (transactions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada transaksi untuk di-export'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // Create CSV content
      final csvBuffer = StringBuffer();

      // Add title and period
      csvBuffer.writeln('LAPORAN PENJUALAN KOPERASI BPS');
      csvBuffer.writeln(
        'Periode: ${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDateRange!.end)}',
      );
      if (_selectedBuyer != null && _selectedBuyer!.isNotEmpty) {
        csvBuffer.writeln('Filter Pembeli: $_selectedBuyer');
      }
      csvBuffer.writeln('');

      // Add headers
      csvBuffer.writeln('No,Tanggal,Waktu,Customer,Item,Penjualan,Modal,Laba');

      // Add data
      double totalSales = 0;
      double totalCost = 0;
      double totalProfit = 0;

      for (var i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        totalSales += transaction.totalHargaJual;
        totalCost += transaction.totalHargaBeli;
        totalProfit += transaction.totalLaba;

        final itemsText = transaction.items
            .map((item) => '${item.nama} (${item.qty}x)')
            .join('; '); // Use semicolon instead of comma for items

        csvBuffer.writeln(
          [
            i + 1,
            DateFormat('dd/MM/yyyy').format(transaction.transactionDate),
            DateFormat('HH:mm').format(transaction.transactionDate),
            '"${transaction.customerName}"', // Quote to handle commas in names
            '"$itemsText"', // Quote to handle commas/semicolons
            transaction.totalHargaJual.toInt(),
            transaction.totalHargaBeli.toInt(),
            transaction.totalLaba.toInt(),
          ].join(','),
        );
      }

      // Add totals
      csvBuffer.writeln('');
      csvBuffer.writeln(
        ',,,,TOTAL:,${totalSales.toInt()},${totalCost.toInt()},${totalProfit.toInt()}',
      );

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Laporan_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(csvBuffer.toString(), encoding: utf8);

      // Share file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Laporan Penjualan Koperasi BPS',
        text:
            'Laporan penjualan periode ${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDateRange!.end)}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File CSV berhasil dibuat'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat CSV: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
