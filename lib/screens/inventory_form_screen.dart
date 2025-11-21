import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/jajanan_provider.dart';
import '../providers/jajanan_sync_provider.dart';
import '../models/jajanan.dart';

class InventoryFormScreen extends StatefulWidget {
  final Jajanan? item;

  const InventoryFormScreen({super.key, this.item});

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaBeliController = TextEditingController();
  final _hargaJualController = TextEditingController();
  final _stokController = TextEditingController();

  String? _selectedCategory;
  String? _fotoPath;
  bool _isCustomCategory = false;
  final _customCategoryController = TextEditingController();
  bool _isSaving = false;

  bool get _isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _namaController.text = widget.item!.nama;
      _hargaBeliController.text = widget.item!.hargaBeli.toInt().toString();
      _hargaJualController.text = widget.item!.hargaJual.toInt().toString();
      _stokController.text = widget.item!.stok.toString();
      _selectedCategory = widget.item!.kategori;
      _fotoPath = widget.item!.fotoPath;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    _stokController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            _buildPhotoSection(),
            const SizedBox(height: 24),
            _buildNamaField(),
            const SizedBox(height: 16),
            _buildCategorySection(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildHargaBeliField()),
                const SizedBox(width: 16),
                Expanded(child: _buildHargaJualField()),
              ],
            ),
            const SizedBox(height: 16),
            _buildStokField(),
            const SizedBox(height: 24),
            _buildEstimasiLaba(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textLight.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _fotoPath != null
                ? Image.file(
                    File(_fotoPath!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: AppColors.error,
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Icon(
                      Icons.add_photo_alternate,
                      size: 60,
                      color: AppColors.textLight,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Kamera'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galeri'),
            ),
            if (_fotoPath != null) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => setState(() => _fotoPath = null),
                icon: const Icon(Icons.delete),
                label: const Text('Hapus'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildNamaField() {
    return TextFormField(
      controller: _namaController,
      decoration: const InputDecoration(
        labelText: 'Nama Produk *',
        prefixIcon: Icon(Icons.shopping_bag_outlined),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nama produk harus diisi';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySection() {
    return Consumer<JajananProvider>(
      builder: (context, provider, _) {
        final categories = [
          ...AppConstants.defaultCategories,
          ...provider.categories,
        ].toSet().toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _isCustomCategory
                      ? TextFormField(
                          controller: _customCategoryController,
                          decoration: InputDecoration(
                            labelText: 'Kategori Baru *',
                            prefixIcon: const Icon(Icons.category_outlined),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.arrow_drop_down),
                              onPressed: () {
                                setState(() => _isCustomCategory = false);
                              },
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (_isCustomCategory &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Kategori harus diisi';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() => _selectedCategory = value);
                          },
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: categories.contains(_selectedCategory)
                              ? _selectedCategory
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Kategori *',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCategory = value);
                          },
                          validator: (value) {
                            if (!_isCustomCategory && value == null) {
                              return 'Kategori harus dipilih';
                            }
                            return null;
                          },
                        ),
                ),
                const SizedBox(width: 8),
                if (!_isCustomCategory)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: AppColors.primary,
                    onPressed: () {
                      setState(() {
                        _isCustomCategory = true;
                        _customCategoryController.text =
                            _selectedCategory ?? '';
                      });
                    },
                    tooltip: 'Tambah kategori baru',
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildHargaBeliField() {
    return TextFormField(
      controller: _hargaBeliController,
      decoration: const InputDecoration(
        labelText: 'Harga Beli *',
        prefixIcon: Icon(Icons.money_off),
        prefixText: 'Rp ',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Harga beli harus diisi';
        }
        final hargaBeli = int.tryParse(value);
        if (hargaBeli == null || hargaBeli <= 0) {
          return 'Harga beli tidak valid';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildHargaJualField() {
    return TextFormField(
      controller: _hargaJualController,
      decoration: const InputDecoration(
        labelText: 'Harga Jual *',
        prefixIcon: Icon(Icons.attach_money),
        prefixText: 'Rp ',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Harga jual harus diisi';
        }
        final hargaJual = int.tryParse(value);
        if (hargaJual == null || hargaJual <= 0) {
          return 'Harga jual tidak valid';
        }
        final hargaBeli = int.tryParse(_hargaBeliController.text);
        if (hargaBeli != null && hargaJual < hargaBeli) {
          return 'Harga jual < harga beli!';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildStokField() {
    return TextFormField(
      controller: _stokController,
      decoration: const InputDecoration(
        labelText: 'Stok *',
        prefixIcon: Icon(Icons.inventory_2_outlined),
        suffixText: 'pcs',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Stok harus diisi';
        }
        final stok = int.tryParse(value);
        if (stok == null || stok < 0) {
          return 'Stok tidak valid';
        }
        return null;
      },
    );
  }

  Widget _buildEstimasiLaba() {
    final hargaBeli = int.tryParse(_hargaBeliController.text) ?? 0;
    final hargaJual = int.tryParse(_hargaJualController.text) ?? 0;
    final laba = hargaJual - hargaBeli;
    final persentase = hargaBeli > 0 ? ((laba / hargaBeli) * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: laba >= 0
            ? AppColors.primaryGradient
            : LinearGradient(
                colors: [
                  AppColors.error,
                  AppColors.error.withValues(alpha: 0.7),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Estimasi Laba per Item',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp',
                      decimalDigits: 0,
                    ).format(laba),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nominal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.textOnPrimary.withValues(alpha: 0.3),
              ),
              Column(
                children: [
                  Text(
                    '${persentase.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Persentase',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveItem,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save),
        label: Text(
          _isSaving
              ? 'Menyimpan...'
              : (_isEditMode ? 'Update Produk' : 'Simpan Produk'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textOnAccent,
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      if (pickedFile != null) {
        // Validate file exists
        final file = File(pickedFile.path);
        if (await file.exists()) {
          setState(() {
            _fotoPath = pickedFile.path;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto berhasil dipilih'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 1),
              ),
            );
          }
        } else {
          throw Exception('File tidak ditemukan');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveItem() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final category = _isCustomCategory
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    if (category == null || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori harus diisi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final item = Jajanan(
        id: _isEditMode
            ? widget.item!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        nama: _namaController.text.trim(),
        hargaBeli: double.parse(_hargaBeliController.text),
        hargaJual: double.parse(_hargaJualController.text),
        stok: int.parse(_stokController.text),
        kategori: category,
        fotoPath: _fotoPath,
        createdAt: _isEditMode ? widget.item!.createdAt : null,
      );

      final provider = context.read<JajananProvider>();
      final syncProvider = context.read<JajananSyncProvider>();

      if (_isEditMode) {
        await provider.updateItem(item);
      } else {
        await provider.addItem(item);
      }

      // Sync to Firestore (don't await, let it run in background)
      syncProvider.syncToFirestore(item).catchError((e) {
        // Ignore sync errors, data already saved locally
        debugPrint('Sync error: $e');
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Produk berhasil diupdate'
                  : 'Produk berhasil ditambahkan',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
