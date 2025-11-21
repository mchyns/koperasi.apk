import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/jajanan_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/transaction_sync_provider.dart';
import '../models/jajanan.dart';
import '../models/transaction.dart';
import '../widgets/customer_combo_box.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir - POS'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: cart.isEmpty
                        ? null
                        : () => _showCheckoutDialog(),
                    tooltip: 'Checkout',
                  ),
                  if (cart.totalQty > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cart.totalQty}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildProductSection(),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _showCheckoutDialog(),
            backgroundColor: AppColors.accent,
            icon: const Icon(Icons.shopping_cart_checkout),
            label: Text('Checkout (${cart.totalQty})'),
          );
        },
      ),
    );
  }

  Widget _buildProductSection() {
    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(child: _buildProductGrid()),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value.toLowerCase());
            },
          ),
          const SizedBox(height: 8),
          // Category Filter
          Consumer<JajananProvider>(
            builder: (context, provider, _) {
              final categories = ['Semua', ...provider.categories];
              return SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == 'Semua'
                        ? _selectedCategory == null
                        : _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          category,
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category == 'Semua'
                                ? null
                                : category;
                          });
                        },
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        selectedColor: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<JajananProvider>(
      builder: (context, jajananProvider, _) {
        var items = jajananProvider.availableItems;

        // Filter by search
        if (_searchQuery.isNotEmpty) {
          items = items.where((item) {
            return item.nama.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        // Filter by category
        if (_selectedCategory != null) {
          items = items.where((item) {
            return item.kategori == _selectedCategory;
          }).toList();
        }

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty || _selectedCategory != null
                      ? 'Produk tidak ditemukan'
                      : 'Belum ada produk tersedia',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildProductCard(items[index]);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Jajanan item) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final inCart = cart.containsItem(item.id);
        final qtyInCart = cart.getItemQty(item.id);

        return Card(
          margin: EdgeInsets.zero,
          elevation: inCart ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: inCart
                ? const BorderSide(color: AppColors.accent, width: 1.5)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () => _addToCart(item),
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image placeholder
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                    child: item.fotoPath != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            child: Image.file(
                              File(item.fotoPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholderIcon(),
                            ),
                          )
                        : _buildPlaceholderIcon(),
                  ),
                ),
                // Info
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.nama,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currencyFormat.format(item.hargaJual),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: item.isStokRendah
                                  ? AppColors.warning.withValues(alpha: 0.2)
                                  : AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'Stok: ${item.stok}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: item.isStokRendah
                                    ? AppColors.warning
                                    : AppColors.success,
                              ),
                            ),
                          ),
                          if (inCart)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.shopping_cart,
                                    size: 9,
                                    color: AppColors.textOnAccent,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$qtyInCart',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textOnAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Icon(Icons.fastfood, size: 40, color: AppColors.primary);
  }

  void _addToCart(Jajanan item) {
    final cart = context.read<CartProvider>();
    cart.addItem(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.nama} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCheckoutDialog() {
    String customerName = '';
    String? errorText;
    bool isProcessing = false;
    final cart = context.read<CartProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Checkout'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Input
                  CustomerComboBox(
                    onChanged: (value) {
                      customerName = value;
                      if (errorText != null) {
                        setDialogState(() => errorText = null);
                      }
                    },
                    errorText: errorText,
                  ),
                  const SizedBox(height: 16),
                  // Cart Items List
                  const Text(
                    'Item Pesanan:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 8),
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.nama,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Qty controls
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      cart.decrementItem(item.jajananId);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      size: 14,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '${item.qty}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: item.qty < item.maxStok
                                      ? () {
                                          setDialogState(() {
                                            cart.incrementItem(item.jajananId);
                                          });
                                        }
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: item.qty < item.maxStok
                                          ? AppColors.success.withValues(
                                              alpha: 0.1,
                                            )
                                          : AppColors.textLight.withValues(
                                              alpha: 0.1,
                                            ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 14,
                                      color: item.qty < item.maxStok
                                          ? AppColors.success
                                          : AppColors.textLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currencyFormat.format(item.hargaJual * item.qty),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Summary
                  Consumer<CartProvider>(
                    builder: (context, cart, _) => Column(
                      children: [
                        _buildCheckoutSummaryRow(
                          'Total Item',
                          cart.totalQty.toString(),
                        ),
                        _buildCheckoutSummaryRow(
                          'Total Harga',
                          _currencyFormat.format(cart.totalHargaJual),
                        ),
                        _buildCheckoutSummaryRow(
                          'Estimasi Laba',
                          _currencyFormat.format(cart.totalLaba),
                          isProfit: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () async {
                      setDialogState(() => isProcessing = true);
                      await _processCheckout(
                        customerName,
                        setDialogState,
                        (error) => setDialogState(() {
                          errorText = error;
                          isProcessing = false;
                        }),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textOnAccent,
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Selesaikan Transaksi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSummaryRow(
    String label,
    String value, {
    bool isProfit = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isProfit ? AppColors.profit : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout(
    String customerName,
    StateSetter setDialogState,
    Function(String?) setError,
  ) async {
    if (customerName.trim().isEmpty) {
      setError('Nama pembeli harus diisi');
      return;
    }

    try {
      final cart = context.read<CartProvider>();
      final customerProvider = context.read<CustomerProvider>();
      final transactionProvider = context.read<TransactionProvider>();
      final jajananProvider = context.read<JajananProvider>();

      // Get or create customer
      final customer = await customerProvider.addOrGetCustomer(customerName);

      // Create transaction items
      final transactionItems = cart.items.map((cartItem) {
        return TransactionItem(
          jajananId: cartItem.jajananId,
          nama: cartItem.nama,
          hargaBeli: cartItem.hargaBeli,
          hargaJual: cartItem.hargaJual,
          qty: cartItem.qty,
        );
      }).toList();

      // Create transaction
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: customer.id,
        customerName: customer.nama,
        items: transactionItems,
        totalHargaBeli: cart.totalHargaBeli,
        totalHargaJual: cart.totalHargaJual,
        totalLaba: cart.totalLaba,
      );

      // Save transaction
      await transactionProvider.addTransaction(transaction);

      // Sync to Firestore (don't await, let it run in background)
      final transactionSyncProvider = context.read<TransactionSyncProvider>();
      transactionSyncProvider.syncToFirestore(transaction).catchError((e) {
        // Ignore sync errors, data already saved locally
        debugPrint('Sync error: $e');
      });

      // Update customer stats
      customer.updateAfterTransaction(cart.totalHargaJual);
      await customerProvider.updateCustomer(customer);

      // Update stock for all items
      for (final cartItem in cart.items) {
        await jajananProvider.reduceStock(cartItem.jajananId, cartItem.qty);
      }

      // Clear cart
      cart.clear();

      // Close dialog immediately
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transaksi berhasil! Total: ${_currencyFormat.format(transaction.totalHargaJual)}',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setDialogState(() => setError('Gagal memproses: $e'));
    }
  }
}
