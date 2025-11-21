import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/settings_provider.dart';
import 'main_navigation_screen.dart';

class PinLockScreen extends StatefulWidget {
  final bool isSettingPin;
  final bool isChangingPin;

  const PinLockScreen({
    super.key,
    this.isSettingPin = false,
    this.isChangingPin = false,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _pin = '';
  int _attempts = 0;
  bool _isLocked = false;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_isLocked || _pin.length >= AppConstants.pinLength) return;

    setState(() {
      _pin += number;
    });

    HapticFeedback.lightImpact();

    if (_pin.length == AppConstants.pinLength) {
      _verifyPin();
    }
  }

  void _onBackspacePressed() {
    if (_isLocked || _pin.isEmpty) return;

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });

    HapticFeedback.selectionClick();
  }

  Future<void> _verifyPin() async {
    final settingsProvider = context.read<SettingsProvider>();

    if (widget.isSettingPin) {
      // Setting new PIN
      await settingsProvider.setPin(_pin);
      await settingsProvider.setPinEnabled(true);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
      return;
    }

    // Verifying existing PIN
    if (settingsProvider.verifyPin(_pin)) {
      // Correct PIN
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } else {
      // Wrong PIN
      _attempts++;
      HapticFeedback.heavyImpact();

      setState(() {
        _pin = '';
      });

      if (_attempts >= AppConstants.maxPinAttempts) {
        // Lock out for 30 seconds
        _startLockout();
      } else {
        _showSnackBar(
          'PIN Salah! ${AppConstants.maxPinAttempts - _attempts} percobaan tersisa.',
        );
      }
    }
  }

  void _startLockout() {
    setState(() {
      _isLocked = true;
      _lockoutSeconds = AppConstants.lockoutDurationSeconds;
      _pin = '';
    });

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _lockoutSeconds--;
      });

      if (_lockoutSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isLocked = false;
          _attempts = 0;
        });
      }
    });

    _showSnackBar('Terlalu banyak percobaan! Tunggu $_lockoutSeconds detik.');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Logo dan Title
            _buildHeader(),
            const SizedBox(height: 48),
            // PIN Dots
            _buildPinDots(),
            const SizedBox(height: 24),
            // Status Text
            _buildStatusText(),
            const Spacer(),
            // Keypad
            _buildKeypad(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 40,
            color: AppColors.textOnAccent,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.isSettingPin ? 'Buat PIN Baru' : AppConstants.appName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.isSettingPin
              ? 'Masukkan 6 digit PIN'
              : 'Masukkan PIN untuk melanjutkan',
          style: const TextStyle(fontSize: 14, color: AppColors.accentLight),
        ),
      ],
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(AppConstants.pinLength, (index) {
        final isFilled = index < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.accent : Colors.transparent,
            border: Border.all(color: AppColors.accentLight, width: 2),
          ),
        );
      }),
    );
  }

  Widget _buildStatusText() {
    if (_isLocked) {
      return Text(
        'Coba lagi dalam $_lockoutSeconds detik',
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.accentLight,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (_attempts > 0 && !_isLocked) {
      return Text(
        '${AppConstants.maxPinAttempts - _attempts} percobaan tersisa',
        style: const TextStyle(fontSize: 14, color: AppColors.accentLight),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3']),
          const SizedBox(height: 16),
          _buildKeypadRow(['4', '5', '6']),
          const SizedBox(height: 16),
          _buildKeypadRow(['7', '8', '9']),
          const SizedBox(height: 16),
          _buildKeypadRow(['', '0', 'back']),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) => _buildKeypadButton(number)).toList(),
    );
  }

  Widget _buildKeypadButton(String value) {
    if (value.isEmpty) return const SizedBox(width: 72, height: 72);

    final isBackspace = value == 'back';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLocked
            ? null
            : () {
                if (isBackspace) {
                  _onBackspacePressed();
                } else {
                  _onNumberPressed(value);
                }
              },
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.accentLight.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: isBackspace
                ? const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.textOnPrimary,
                    size: 24,
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
