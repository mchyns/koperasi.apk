/// Konstanta global aplikasi Koperasi BPS
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Koperasi BPS';
  static const String appVersion = '1.0.0';
  static const String developer = 'mchyns';

  // PIN Configuration
  static const int pinLength = 6;
  static const int maxPinAttempts = 3;
  static const int lockoutDurationSeconds = 30;

  // Database Keys
  static const String hiveBoxJajanan = 'jajanan_box';
  static const String hiveBoxCustomers = 'customers_box';
  static const String hiveBoxTransactions = 'transactions_box';
  static const String hiveBoxSettings = 'settings_box';

  // Settings Keys
  static const String settingsPinEnabled = 'pin_enabled';
  static const String settingsPin = 'pin_code';
  static const String settingsMonthlyBudget = 'monthly_budget';

  // Default Customer Names (from BPS staff list)
  static const List<String> defaultCustomerNames = [
    'Insaf Santoso SST, M.Si.',
    'Zhoemaroh SE, MM',
    'Abdul Mokti',
    'Nia Nurma Faiza A.Md, SE',
    'Ach. Haris Sidik SE',
    'Alfin Niam Habibi A.Md. Stat',
    'Anggraini Nur Agustina A.Md.Stat.',
    'Aris Kuswantoro SE.,M.M.',
    'Citra Dian Etika S.Si',
    'Dhony Susfantori S.M.',
    'Dwi Muklis SST',
    'Dwi Widianis SST, SE.,M.Si',
    'Erlisa Wahyu Pratiwi S.Si',
    'Hendra Adhikara S.ST, MM',
    'Heru Priambodo SE',
    'Hizbullah Gunawan SE., MM',
    'Indah Putri Rahayu S.Si.',
    'Ir. Hariyanto MM',
    'Istian Hendriyanto A.Md',
    'Linda Kuncasari S.Tr.Stat.',
    'Mohammad Sakir SE, M.M',
    'Mohammad Soleh TC SE',
    'Mohlis S.E.',
    'Ridnu Witardi S.E.',
    'Tatok Mulyo Mintartok S.Sos',
    'Tedy Wahyudi SE, MM',
    'Whistra Pariata Utama A.Md',
    'Yeni Arisanti SE, MM.',
    'Radita Nareswari Mumpuni Putri S.Tr.Stat.',
    'Peni Dwi Wahyu Winarsi S.Stat.',
  ];

  // Default Categories
  static const List<String> defaultCategories = [
    'Minuman',
    'Snack',
    'Makanan',
    'Roti',
    'Kue',
    'Permen',
    'Coklat',
    'Lainnya',
  ];

  // Formatting
  static const String currencySymbol = 'Rp';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Stock Thresholds
  static const int lowStockThreshold = 10;

  // Pagination
  static const int itemsPerPage = 20;

  // Image Configuration (untuk keep size kecil)
  static const int maxImageWidth = 800;
  static const int maxImageHeight = 800;
  static const int imageQuality = 85;
}
