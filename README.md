# Koperasi BPS - Point of Sale & Inventory Management

**Developer:** mchyns  
**Version:** 1.0.0

Aplikasi Point of Sale (POS) dan Manajemen Inventaris internal untuk admin Koperasi BPS. Aplikasi ini dirancang khusus untuk admin dengan fitur-fitur canggih namun tetap ringan dan responsif.

## 🎯 Fitur Utama

### 1. **Keamanan PIN Lock** ✅
- PIN 6 digit untuk melindungi akses aplikasi
- Sistem lockout 30 detik setelah 3x percobaan gagal
- Animasi shake dan haptic feedback untuk pengalaman lebih baik
- Toggle enable/disable PIN di Pengaturan

### 2. **Dashboard Real-time** ✅
- Ringkasan penjualan hari ini (Total Penjualan, Laba, Persentase)
- Tracking budget bulanan dengan progress bar visual
- Status stok real-time (Total, Tersedia, Rendah, Habis)
- Pull-to-refresh untuk update data instant
- Animasi smooth dengan flutter_animate

### 3. **Point of Sale (Kasir)** 🚧
- Sistem keranjang belanja yang intuitif
- Grid produk dengan stok tersedia
- Checkout cepat dengan ComboBox nama pelanggan
- Auto-update stok setelah transaksi
- Perhitungan laba otomatis per transaksi

### 4. **Manajemen Inventaris** 🚧
- CRUD lengkap untuk item jajanan
- Upload foto produk (opsional)
- Kategori dinamis (bisa tambah kategori baru)
- Label visual untuk stok habis/rendah
- Filter dan pencarian produk

### 5. **Laporan & Keuangan** 🚧
- Filter laporan by tanggal, bulan, atau range
- Perhitungan otomatis: Penjualan, Modal, Laba Bersih
- Ekspor ke Excel (.xlsx) dengan 1 tap
- Share laporan via WhatsApp/Email/Save

### 6. **Manajemen Pelanggan** ✅
- 30 nama karyawan BPS sudah ter-preset
- Tambah pelanggan baru otomatis saat checkout
- History transaksi per pelanggan

## 🎨 Design & Branding

- **Warna Primer:** Biru BPS (#003B73)
- **Warna Aksen:** Kuning Emas (#F9A825)
- **Font:** Poppins (Google Fonts) untuk tampilan profesional
- **Animasi:** Smooth transitions dengan flutter_animate
- **Tema:** Material Design 3 dengan custom BPS color scheme

## 📦 Teknologi

### Dependencies Utama
```yaml
- provider: ^6.1.2              # State management (lightweight)
- hive: ^2.2.3                  # Local database (fast & small)
- hive_flutter: ^1.1.0
- google_fonts: ^6.2.1          # Font Poppins
- flutter_animate: ^4.5.0       # Smooth animations
- percent_indicator: ^4.2.3     # Budget progress bar
- excel: ^4.0.3                 # Export to Excel
- share_plus: ^10.1.2           # Native sharing
- image_picker: ^1.1.2          # Photo upload
- flutter_secure_storage: ^9.2.2 # Secure PIN storage
- intl: ^0.19.0                 # Formatting tanggal & currency
```

### Ukuran Aplikasi
- Target size: **< 30MB** (optimized untuk performa Android)
- Image compression: Max 800x800, 85% quality
- On-demand font loading dengan google_fonts
- Minimal dependencies untuk keep size kecil

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter SDK 3.10.0 atau lebih baru
- Dart SDK 3.10.0 atau lebih baru
- Android Studio / VS Code dengan Flutter extension

### Instalasi & Running

```bash
# Clone atau extract project
cd koperasi

# Install dependencies
flutter pub get

# Generate Hive adapters (sudah di-generate)
flutter pub run build_runner build --delete-conflicting-outputs

# Run di emulator/device
flutter run

# Build APK untuk production
flutter build apk --release

# Build APK dengan split per ABI (ukuran lebih kecil)
flutter build apk --split-per-abi --release
```

### Build untuk Android (Optimized)

```bash
# Build APK dengan optimasi size
flutter build apk --release --target-platform android-arm64 --analyze-size

# Hasilnya ada di: build/app/outputs/flutter-apk/app-release.apk
```

## 📱 Struktur Project

```
lib/
├── constants/
│   ├── app_colors.dart       # Palet warna BPS
│   ├── app_theme.dart        # Theme Material 3 custom
│   └── app_constants.dart    # Konstanta global
├── models/
│   ├── jajanan.dart          # Model Produk + Hive adapter
│   ├── customer.dart         # Model Pelanggan
│   ├── transaction.dart      # Model Transaksi + TransactionItem
│   └── cart_item.dart        # Model Keranjang
├── providers/
│   ├── jajanan_provider.dart       # State management produk
│   ├── customer_provider.dart      # State management pelanggan
│   ├── transaction_provider.dart   # State management transaksi
│   ├── cart_provider.dart          # State management keranjang
│   └── settings_provider.dart      # State management pengaturan
├── screens/
│   ├── splash_screen.dart          # Splash dengan animasi ✅
│   ├── pin_lock_screen.dart        # PIN Lock dengan timer ✅
│   ├── main_navigation_screen.dart # Bottom navigation bar ✅
│   ├── dashboard_screen.dart       # Dashboard utama ✅
│   ├── pos_screen.dart             # POS/Kasir 🚧
│   ├── inventory_screen.dart       # Manajemen stok 🚧
│   ├── reports_screen.dart         # Laporan 🚧
│   └── settings_screen.dart        # Pengaturan 🚧
├── widgets/                        # Reusable widgets
└── main.dart                       # Entry point ✅
```

## 🎯 Default Data

### Nama Pelanggan (30 Karyawan BPS)
Sudah ter-preset di `AppConstants.defaultCustomerNames`:
- Insaf Santoso SST, M.Si.
- Zhoemaroh SE, MM
- Abdul Mokti
- ... (30 nama total)

### Kategori Default
- Minuman
- Snack
- Makanan
- Roti
- Kue
- Permen
- Coklat
- Lainnya

## 🔐 Keamanan

- PIN disimpan di **Flutter Secure Storage** (encrypted)
- Lockout mechanism: 30 detik setelah 3x gagal
- Data lokal menggunakan Hive (tidak ter-expose ke internet)

## ⚡ Performance & Optimization

1. **Lightweight State Management:** Provider (bukan Riverpod yang lebih berat)
2. **Fast Local DB:** Hive (NoSQL, lebih cepat dari SQLite)
3. **On-demand Font Loading:** Google Fonts caching
4. **Image Optimization:** Max 800x800, 85% quality
5. **Lazy Loading:** IndexedStack untuk bottom navigation
6. **Minimal Dependencies:** Hanya package essential

## 🎨 Animasi & UX

- **Splash Screen:** Logo scaling + shimmer effect
- **PIN Screen:** Shake animation saat salah, pulse dots
- **Dashboard:** Staggered fade-in untuk cards
- **Pull-to-Refresh:** Native material refresh indicator
- **Haptic Feedback:** Light impact untuk tap, heavy untuk error

## 🐛 Troubleshooting

### Build Runner Error
```bash
# Clean dan re-generate
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Hive Error: Box not initialized
Pastikan di `main.dart` sudah ada:
```dart
await Hive.initFlutter();
await Hive.openBox<Jajanan>(AppConstants.hiveBoxJajanan);
// ... boxes lainnya
```

### withOpacity Deprecation Warnings
Ini hanya warning, bukan error. App tetap jalan normal.

## 📝 Progress Status

- [x] Project scaffolding & theme
- [x] Data models & Hive setup
- [x] State management (Provider)
- [x] PIN Lock Screen dengan timer
- [x] Splash Screen dengan animasi
- [x] Dashboard real-time
- [ ] POS Screen dengan Cart
- [ ] Customer ComboBox widget
- [ ] Inventory Management
- [ ] Reports & Excel Export
- [ ] Settings Screen

## 📄 License

Proprietary - Internal use only for Koperasi BPS

---

**Developed with ❤️ by mchyns**  
*Koperasi BPS - Badan Pusat Statistik*

