import 'package:flutter/material.dart';

/// Palet warna aplikasi Koperasi BPS
/// Menggunakan warna identitas BPS: Biru Tua dan Kuning Emas
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Warna Utama BPS (Biru)
  static const Color primary = Color(0xFF003B73); // Biru BPS
  static const Color primaryDark = Color(0xFF002347);
  static const Color primaryLight = Color(0xFF1A5590);

  // Warna Aksen BPS (Kuning/Emas)
  static const Color accent = Color(0xFFF9A825); // Kuning Emas BPS
  static const Color accentDark = Color(0xFFC17900);
  static const Color accentLight = Color(0xFFFFD54F);

  // Warna Netral
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA);

  // Warna Teks
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF212121);

  // Warna Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Warna Khusus
  static const Color stockEmpty = Color(0xFFE53935); // Merah untuk stok habis
  static const Color stockLow = Color(0xFFFF9800); // Orange untuk stok rendah
  static const Color profit = Color(0xFF4CAF50); // Hijau untuk laba
  static const Color loss = Color(0xFFF44336); // Merah untuk rugi

  // Gradients untuk animasi dan visual menarik
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow colors untuk depth
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
}
