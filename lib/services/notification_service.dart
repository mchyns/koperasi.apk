import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _permissionGranted = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (_permissionGranted) return true;

    // Android 13+ requires runtime permission
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _permissionGranted = result ?? true; // true for older Android versions
    return _permissionGranted;
  }

  Future<void> showSyncProgress({
    required int current,
    required int total,
    required String title,
  }) async {
    if (!_permissionGranted) return;

    final androidDetails = AndroidNotificationDetails(
      'sync_channel',
      'Sinkronisasi',
      channelDescription: 'Notifikasi untuk proses sinkronisasi data',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: total,
      progress: current,
      ongoing: true,
      autoCancel: false,
      playSound: false,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1, // notification ID for sync
      title,
      '$current dari $total item',
      notificationDetails,
    );
  }

  Future<void> showSyncComplete({
    required String title,
    required String message,
    bool isSuccess = true,
  }) async {
    if (!_permissionGranted) return;

    final androidDetails = AndroidNotificationDetails(
      'sync_channel',
      'Sinkronisasi',
      channelDescription: 'Notifikasi untuk proses sinkronisasi data',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1, // same ID to replace progress notification
      title,
      message,
      notificationDetails,
    );

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _notifications.cancel(1);
    });
  }

  Future<void> cancelSyncNotification() async {
    await _notifications.cancel(1);
  }
}
