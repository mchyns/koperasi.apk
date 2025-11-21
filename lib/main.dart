import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_theme.dart';
import 'constants/app_constants.dart';
import 'models/jajanan.dart';
import 'models/customer.dart';
import 'models/transaction.dart';
import 'models/cart_item.dart';
import 'providers/jajanan_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/jajanan_sync_provider.dart';
import 'providers/transaction_sync_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Set preferred orientations (portrait only untuk konsistensi)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(JajananAdapter());
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(TransactionItemAdapter());
  Hive.registerAdapter(CartItemAdapter());

  // Open Boxes
  await Hive.openBox<Jajanan>(AppConstants.hiveBoxJajanan);
  await Hive.openBox<Customer>(AppConstants.hiveBoxCustomers);
  await Hive.openBox<Transaction>(AppConstants.hiveBoxTransactions);
  await Hive.openBox(AppConstants.hiveBoxSettings);

  runApp(const KoperasiBPSApp());
}

class KoperasiBPSApp extends StatelessWidget {
  const KoperasiBPSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JajananProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<JajananProvider, JajananSyncProvider>(
          create: (context) => JajananSyncProvider(
            Provider.of<JajananProvider>(context, listen: false),
          ),
          update: (context, jajananProvider, previous) =>
              previous ?? JajananSyncProvider(jajananProvider),
        ),
        ChangeNotifierProxyProvider<
          TransactionProvider,
          TransactionSyncProvider
        >(
          create: (context) => TransactionSyncProvider(
            Provider.of<TransactionProvider>(context, listen: false),
          ),
          update: (context, transactionProvider, previous) =>
              previous ?? TransactionSyncProvider(transactionProvider),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
        locale: const Locale('id', 'ID'),
        home: const SplashScreen(),
      ),
    );
  }
}
