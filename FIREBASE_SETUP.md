# Firebase Multi-Device Sync - Koperasi BPS

## Status Implementasi ✅

Firebase sudah berhasil diintegrasikan! Aplikasi sekarang mendukung sinkronisasi real-time antar perangkat.

## Fitur yang Ditambahkan

### 1. **Google Sign-In Authentication**
- Login menggunakan akun Google
- Satu akun bisa digunakan di beberapa HP
- Mode offline tetap tersedia (lewati login)

### 2. **Real-Time Sync**
- **Inventory (Jajanan)**: Tambah/edit/hapus produk otomatis sync
- **Transaksi**: Semua penjualan tersinkronisasi
- **Offline-First**: Data tersimpan lokal dulu, sync saat online

### 3. **Hybrid Storage**
- **Hive** (lokal): Untuk akses cepat & offline
- **Firestore** (cloud): Untuk sync antar device

## Cara Menggunakan

### Untuk Admin/User Pertama:
1. Buka aplikasi
2. Login dengan Google (atau lewati untuk offline)
3. Data lokal akan otomatis di-upload ke cloud

### Untuk HP Kedua:
1. Install APK yang sama
2. Login dengan akun Google yang sama
3. Data akan otomatis ter-sync dari cloud

### Cara Kerja Sync:
- **Tambah Produk**: Otomatis muncul di HP lain dalam hitungan detik
- **Checkout**: Stok berkurang di semua device
- **Edit/Hapus**: Perubahan langsung tersinkronisasi

## Files yang Ditambahkan/Diubah

### Provider Baru:
- `lib/providers/auth_provider.dart` - Google Sign-In
- `lib/providers/jajanan_sync_provider.dart` - Sync produk
- `lib/providers/transaction_sync_provider.dart` - Sync transaksi

### Screen Baru:
- `lib/screens/login_screen.dart` - Halaman login Google

### Updated Files:
- `lib/main.dart` - Firebase initialization
- `lib/screens/splash_screen.dart` - Route ke login
- `lib/screens/inventory_form_screen.dart` - Sync saat add/edit
- `lib/screens/inventory_screen.dart` - Sync saat delete
- `lib/screens/pos_screen.dart` - Sync saat checkout
- `lib/providers/settings_provider.dart` - Skip login flag
- `lib/providers/jajanan_provider.dart` - Firestore methods
- `lib/providers/transaction_provider.dart` - Firestore methods

### Android Configuration:
- `android/build.gradle.kts` - Google Services plugin
- `android/app/build.gradle.kts` - Firebase config, minSdk 21
- `android/app/google-services.json` - Firebase credentials

## Build Info

**APK Size dengan Firebase:**
- armeabi-v7a: **18.4 MB** ✅ (masih di bawah 20MB!)
- arm64-v8a: **20.6 MB**
- x86_64: **22.0 MB**

Firebase hanya menambah ~2MB dibanding sebelumnya.

## Firebase Console Setup (Sudah Selesai)

✅ Project created
✅ Android app registered
✅ google-services.json downloaded
✅ Authentication enabled
✅ Firestore database ready

## Firestore Database Structure

```
users/
  └── {userId}/
      ├── jajanan/
      │   └── {jajananId}/
      │       ├── id
      │       ├── nama
      │       ├── hargaBeli
      │       ├── hargaJual
      │       ├── stok
      │       ├── kategori
      │       ├── fotoPath
      │       ├── createdAt
      │       └── updatedAt
      │
      └── transactions/
          └── {transactionId}/
              ├── id
              ├── customerId
              ├── customerName
              ├── items[]
              ├── totalHargaBeli
              ├── totalHargaJual
              ├── totalLaba
              └── transactionDate
```

## Mode Operasi

### Online Mode (Login):
- ✅ Data sync real-time
- ✅ Multi-device support
- ✅ Backup otomatis ke cloud

### Offline Mode (Skip Login):
- ✅ Semua fitur tetap jalan
- ✅ Data tersimpan lokal (Hive)
- ❌ Tidak sync antar device

## Testing

Untuk test multi-device sync:

1. **Install di 2 HP**:
   ```bash
   # Transfer APK ke HP kedua
   adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
   ```

2. **Login dengan akun yang sama** di kedua HP

3. **Test sync**:
   - HP 1: Tambah produk baru
   - HP 2: Produk muncul otomatis
   - HP 2: Checkout transaksi
   - HP 1: Stok berkurang otomatis

## Troubleshooting

### Q: Data tidak sync?
A: Pastikan kedua HP login dengan akun Google yang sama dan terkoneksi internet.

### Q: Bisa pakai tanpa login?
A: Bisa! Klik "Lewati (Mode Offline)" di layar login.

### Q: Foto produk ikut sync?
A: Tidak. Foto tersimpan lokal di masing-masing HP. Hanya data teks yang sync.

### Q: Berapa biaya Firebase?
A: **GRATIS** untuk usage normal koperasi. Firestore free tier:
- 50,000 reads/day
- 20,000 writes/day
- 1 GB storage

Lebih dari cukup untuk koperasi kecil-menengah.

## Next Steps (Opsional)

Fitur tambahan yang bisa dikembangkan:
- [ ] Sync foto produk ke Cloud Storage
- [ ] Customer management sync
- [ ] Role management (admin vs kasir)
- [ ] Laporan real-time dashboard
- [ ] Notifikasi stok rendah antar device

---

**Status**: ✅ **READY FOR PRODUCTION**

Aplikasi sudah siap digunakan dengan Firebase sync!
