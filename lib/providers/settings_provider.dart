import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  late Box _box;

  bool _isPinEnabled = false;
  String _pin = '';
  double _monthlyBudget = 0.0;
  bool _hasSkippedLogin = false;

  bool get isPinEnabled => _isPinEnabled;
  String get pin => _pin;
  double get monthlyBudget => _monthlyBudget;
  bool get hasSkippedLogin => _hasSkippedLogin;

  SettingsProvider() {
    _box = Hive.box(AppConstants.hiveBoxSettings);
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isPinEnabled = _box.get(
      AppConstants.settingsPinEnabled,
      defaultValue: false,
    );
    _monthlyBudget = _box.get(
      AppConstants.settingsMonthlyBudget,
      defaultValue: 0.0,
    );
    _pin = _box.get(AppConstants.settingsPin, defaultValue: '');
    _hasSkippedLogin = _box.get('hasSkippedLogin', defaultValue: false);

    notifyListeners();
  }

  Future<void> setPinEnabled(bool enabled) async {
    _isPinEnabled = enabled;
    await _box.put(AppConstants.settingsPinEnabled, enabled);
    notifyListeners();
  }

  Future<void> setPin(String newPin) async {
    _pin = newPin;
    await _box.put(AppConstants.settingsPin, newPin);
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double budget) async {
    _monthlyBudget = budget;
    await _box.put(AppConstants.settingsMonthlyBudget, budget);
    notifyListeners();
  }

  bool verifyPin(String inputPin) {
    return _pin == inputPin;
  }

  Future<void> clearPin() async {
    _pin = '';
    await _box.delete(AppConstants.settingsPin);
    await setPinEnabled(false);
  }

  Future<void> setSkippedLogin(bool skipped) async {
    _hasSkippedLogin = skipped;
    await _box.put('hasSkippedLogin', skipped);
    notifyListeners();
  }
}
