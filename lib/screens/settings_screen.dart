import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/jajanan_sync_provider.dart';
import '../providers/transaction_sync_provider.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'qr_share_screen.dart';
import 'qr_scan_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          _buildAccountSection(context),
          const Divider(height: 1),
          _buildTransferSection(context),
          const Divider(height: 1),
          _buildSyncSection(context),
          const Divider(height: 1),
          _buildSecuritySection(context),
          const Divider(height: 1),
          _buildBudgetSection(context),
          const Divider(height: 1),
          _buildDataSection(context),
          const Divider(height: 1),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Akun',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (user != null)
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(user.displayName ?? 'User'),
                subtitle: Text(user.email ?? ''),
                trailing: const Icon(Icons.verified_user, color: Colors.green),
              ),
            if (user != null)
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Logout'),
                subtitle: const Text('Keluar dari akun Google'),
                onTap: () => _showLogoutDialog(context, authProvider),
              ),
            if (user == null)
              ListTile(
                leading: const Icon(Icons.cloud_off, color: Colors.grey),
                title: const Text('Mode Offline'),
                subtitle: const Text('Login untuk sinkronisasi multi-device'),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text('Login'),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTransferSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            'Transfer Data Offline',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.qr_code_2, color: AppColors.primary),
          title: const Text('Bagikan via QR Code'),
          subtitle: const Text('Generate QR Code untuk dibagikan'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRShareScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.qr_code_scanner, color: AppColors.accent),
          title: const Text('Scan QR Code'),
          subtitle: const Text('Import data dari QR Code'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScanScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSyncSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Sinkronisasi',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (user != null) ...[
              ListTile(
                leading: const Icon(
                  Icons.cloud_upload,
                  color: AppColors.primary,
                ),
                title: const Text('Upload ke Cloud'),
                subtitle: const Text('Upload data lokal ke cloud'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showUploadDialog(context),
              ),
              ListTile(
                leading: const Icon(
                  Icons.cloud_download,
                  color: AppColors.accent,
                ),
                title: const Text('Download dari Cloud'),
                subtitle: const Text('Load data dari device lain'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDownloadDialog(context),
              ),
            ],
            if (user == null)
              ListTile(
                leading: const Icon(Icons.cloud_off, color: Colors.grey),
                title: const Text('Sinkronisasi Tidak Aktif'),
                subtitle: const Text('Login untuk mengaktifkan sync'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Keamanan',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SwitchListTile(
              value: settings.isPinEnabled,
              onChanged: (value) async {
                if (value) {
                  // Enable PIN - show setup dialog
                  await _showSetupPinDialog(context, settings);
                } else {
                  // Disable PIN - verify first
                  await _showDisablePinDialog(context, settings);
                }
              },
              title: const Text('Kunci PIN'),
              subtitle: Text(
                settings.isPinEnabled
                    ? 'PIN diperlukan saat membuka aplikasi'
                    : 'Aplikasi dapat dibuka tanpa PIN',
              ),
              secondary: const Icon(
                Icons.lock_outline,
                color: AppColors.primary,
              ),
            ),
            if (settings.isPinEnabled)
              ListTile(
                leading: const Icon(
                  Icons.key_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Ubah PIN'),
                subtitle: const Text('Ganti kode PIN Anda'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showChangePinDialog(context, settings),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetSection(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Keuangan',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Budget Modal Stok'),
              subtitle: Text(
                settings.monthlyBudget > 0
                    ? NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp',
                        decimalDigits: 0,
                      ).format(settings.monthlyBudget)
                    : 'Belum diatur',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSetBudgetDialog(context, settings),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final stats = provider.getDatabaseStats();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Manajemen Data',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.storage_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Total Transaksi'),
              subtitle: Text('${stats['totalTransactions']} transaksi'),
              trailing: Text(
                '~${stats['estimatedSizeKB']} KB',
                style: const TextStyle(color: AppColors.textLight),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.compress_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Kompaksi Database'),
              subtitle: const Text('Optimalkan penyimpanan'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCompactDialog(context, provider),
            ),
            ListTile(
              leading: const Icon(
                Icons.cleaning_services_outlined,
                color: AppColors.warning,
              ),
              title: const Text('Hapus Data Lama'),
              subtitle: const Text('Hapus transaksi > 2 tahun'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCleanupDialog(context, provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            'Tentang Aplikasi',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline, color: AppColors.primary),
          title: const Text('Versi Aplikasi'),
          subtitle: Text(AppConstants.appVersion),
        ),
        ListTile(
          leading: const Icon(
            Icons.business_outlined,
            color: AppColors.primary,
          ),
          title: const Text('Koperasi BPS'),
          subtitle: const Text('Badan Pusat Statistik'),
        ),
        ListTile(
          leading: const Icon(Icons.code_outlined, color: AppColors.primary),
          title: const Text('Pengembang'),
          subtitle: const Text('mchyns'),
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.store,
                  size: 40,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sistem Manajemen Koperasi',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showSetupPinDialog(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    String? pin;
    String? confirmPin;
    final pinController = TextEditingController();
    final confirmController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Buat PIN Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Buat PIN 6 digit untuk mengamankan aplikasi',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              decoration: const InputDecoration(
                labelText: 'PIN (6 digit)',
                prefixIcon: Icon(Icons.lock),
                counterText: '',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => pin = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi PIN',
                prefixIcon: Icon(Icons.lock_outline),
                counterText: '',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => confirmPin = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pin == null || pin!.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN harus 6 digit'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              if (pin != confirmPin) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN tidak cocok'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textOnAccent,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true && pin != null) {
      await settings.setPinEnabled(true);
      await settings.setPin(pin!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN berhasil diaktifkan'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }

    pinController.dispose();
    confirmController.dispose();
  }

  Future<void> _showDisablePinDialog(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nonaktifkan PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Masukkan PIN Anda untuk konfirmasi',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'PIN',
                prefixIcon: Icon(Icons.lock),
                counterText: '',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final isValid = settings.verifyPin(controller.text);
              if (!isValid && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN salah'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Nonaktifkan'),
          ),
        ],
      ),
    );

    if (result == true) {
      await settings.setPinEnabled(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN berhasil dinonaktifkan'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }

    controller.dispose();
  }

  Future<void> _showChangePinDialog(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    final result = await showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ubah PIN'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPinController,
                decoration: const InputDecoration(
                  labelText: 'PIN Lama',
                  prefixIcon: Icon(Icons.lock_clock),
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPinController,
                decoration: const InputDecoration(
                  labelText: 'PIN Baru',
                  prefixIcon: Icon(Icons.lock),
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPinController,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi PIN Baru',
                  prefixIcon: Icon(Icons.lock_outline),
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final oldPin = oldPinController.text;
              final newPin = newPinController.text;
              final confirmPin = confirmPinController.text;

              if (oldPin.length != 6 || newPin.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN harus 6 digit'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (newPin != confirmPin) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN baru tidak cocok'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.pop(context, {'old': oldPin, 'new': newPin});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textOnAccent,
            ),
            child: const Text('Ubah PIN'),
          ),
        ],
      ),
    );

    if (result != null) {
      final isValid = settings.verifyPin(result['old']!);
      if (!isValid && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN lama salah'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      await settings.setPin(result['new']!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN berhasil diubah'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }

    oldPinController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();
  }

  Future<void> _showSetBudgetDialog(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final controller = TextEditingController(
      text: settings.monthlyBudget > 0
          ? settings.monthlyBudget.toInt().toString()
          : '',
    );

    try {
      final result = await showDialog<double?>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Budget Modal Stok'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tetapkan target budget untuk modal stok jajanan. Progress akan update otomatis saat tambah/edit stok.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Budget Modal (Rp)',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            if (settings.monthlyBudget > 0)
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 0.0),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Hapus'),
              ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Masukkan nominal yang valid'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textOnAccent,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      );

      if (result != null) {
        await settings.setMonthlyBudget(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result > 0
                    ? 'Budget modal stok berhasil diatur'
                    : 'Budget modal stok dihapus',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _showCompactDialog(
    BuildContext context,
    TransactionProvider provider,
  ) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kompaksi Database'),
        content: const Text(
          'Kompaksi database akan mengoptimalkan penyimpanan dan meningkatkan performa aplikasi.\n\nProses ini aman dan tidak menghapus data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                await provider.compactDatabase();
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Database berhasil dioptimalkan'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Kompaksi'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Apakah Anda yakin ingin keluar?\n\nData lokal akan tetap tersimpan, tapi sinkronisasi akan berhenti.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              await authProvider.signOut();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berhasil logout'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUploadDialog(BuildContext context) async {
    final notifService = NotificationService();
    final jajananSync = context.read<JajananSyncProvider>();
    final transactionSync = context.read<TransactionSyncProvider>();
    final authProvider = context.read<AuthProvider>();

    // Cek login
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Initialize notification service first
      await notifService.initialize();

      // Request notification permission
      final permitted = await notifService.requestPermission();
      if (!permitted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin notifikasi diperlukan untuk melihat progress',
              ),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }

      // Show initial notification
      if (permitted) {
        await notifService.showSyncProgress(
          current: 0,
          total: 100,
          title: 'Memulai Sinkronisasi',
        );
      }

      // Listen to progress updates
      void updateProgress() {
        if (!permitted) return;

        int currentJajanan = jajananSync.syncedCount;
        int totalJajanan = jajananSync.totalItems;
        int currentTransaction = transactionSync.syncedCount;
        int totalTransactions = transactionSync.totalItems;

        int totalItems = totalJajanan + totalTransactions;
        int currentItems = currentJajanan + currentTransaction;

        if (totalItems > 0) {
          String title = '';
          if (jajananSync.isSyncing && transactionSync.isSyncing) {
            title = 'Menyinkronkan Data';
          } else if (jajananSync.isSyncing) {
            title = 'Menyinkronkan Produk';
          } else if (transactionSync.isSyncing) {
            title = 'Menyinkronkan Transaksi';
          }

          notifService.showSyncProgress(
            current: currentItems,
            total: totalItems,
            title: title,
          );
        }
      }

      jajananSync.addListener(updateProgress);
      transactionSync.addListener(updateProgress);

      // Run sync
      await Future.wait([
        jajananSync.initialSync(),
        transactionSync.initialSync(),
      ]);

      // Remove listeners
      jajananSync.removeListener(updateProgress);
      transactionSync.removeListener(updateProgress);

      // Show success notification
      int totalSynced = jajananSync.totalItems + transactionSync.totalItems;
      if (permitted) {
        await notifService.showSyncComplete(
          title: 'Sinkronisasi Selesai',
          message: '$totalSynced item berhasil disinkronkan',
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ $totalSynced item berhasil disinkronkan'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error notification
      try {
        await notifService.showSyncComplete(
          title: 'Sinkronisasi Gagal',
          message: e.toString(),
          isSuccess: false,
        );
      } catch (_) {
        // Ignore notification errors
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Gagal: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showDownloadDialog(BuildContext context) async {
    final notifService = NotificationService();
    final jajananSync = context.read<JajananSyncProvider>();
    final transactionSync = context.read<TransactionSyncProvider>();
    final authProvider = context.read<AuthProvider>();

    // Cek login
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Download dari Cloud'),
        content: const Text(
          'Ini akan mengunduh semua data dari cloud dan menggabungkannya dengan data lokal. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Download'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    // Initialize notification service
    await notifService.initialize();

    // Request notification permission
    final permitted = await notifService.requestPermission();
    if (!permitted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin notifikasi diperlukan untuk melihat progress'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 3),
        ),
      );
    }

    try {
      // Show initial notification
      if (permitted) {
        await notifService.showSyncProgress(
          current: 0,
          total: 100,
          title: 'Memulai Download',
        );
      }

      // Listen to progress updates
      void updateProgress() {
        if (!permitted) return;

        int currentJajanan = jajananSync.syncedCount;
        int totalJajanan = jajananSync.totalItems;
        int currentTransaction = transactionSync.syncedCount;
        int totalTransactions = transactionSync.totalItems;

        int totalItems = totalJajanan + totalTransactions;
        int currentItems = currentJajanan + currentTransaction;

        if (totalItems > 0) {
          String title = '';
          if (jajananSync.isSyncing && transactionSync.isSyncing) {
            title = 'Mengunduh Data';
          } else if (jajananSync.isSyncing) {
            title = 'Mengunduh Produk';
          } else if (transactionSync.isSyncing) {
            title = 'Mengunduh Transaksi';
          }

          notifService.showSyncProgress(
            current: currentItems,
            total: totalItems,
            title: title,
          );
        }
      }

      jajananSync.addListener(updateProgress);
      transactionSync.addListener(updateProgress);

      // Run download
      await Future.wait([
        jajananSync.downloadFromFirestore(),
        transactionSync.downloadFromFirestore(),
      ]);

      // Remove listeners
      jajananSync.removeListener(updateProgress);
      transactionSync.removeListener(updateProgress);

      // Show success notification
      int totalDownloaded =
          jajananSync.syncedCount + transactionSync.syncedCount;
      if (permitted) {
        await notifService.showSyncComplete(
          title: 'Download Selesai',
          message: '$totalDownloaded item berhasil diunduh',
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ $totalDownloaded item berhasil diunduh dari cloud',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Show error notification
      if (permitted) {
        try {
          await notifService.showSyncComplete(
            title: 'Download Gagal',
            message: e.toString(),
            isSuccess: false,
          );
        } catch (_) {
          // Ignore notification errors
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Gagal download: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showCleanupDialog(
    BuildContext context,
    TransactionProvider provider,
  ) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Data Lama'),
        content: const Text(
          'Fitur ini akan menghapus transaksi yang lebih dari 2 tahun untuk menghemat ruang penyimpanan.\n\n⚠️ Data yang dihapus tidak dapat dikembalikan!\n\nPastikan sudah backup laporan sebelum melanjutkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                final deleted = await provider.autoCleanupOldData();
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        deleted > 0
                            ? '$deleted transaksi lama berhasil dihapus'
                            : 'Tidak ada data lama yang perlu dihapus',
                      ),
                      backgroundColor: deleted > 0
                          ? AppColors.success
                          : AppColors.info,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
