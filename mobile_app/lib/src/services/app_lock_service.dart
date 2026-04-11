import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';

import '../models/app_lock_config.dart';
import '../settings/app_preferences_storage.dart';
import '../utils/app_logger.dart';

class AppLockService {
  AppLockService({
    required AppPreferencesStorage preferencesStorage,
    LocalAuthentication? localAuthentication,
  }) : _preferencesStorage = preferencesStorage,
       _localAuthentication = localAuthentication ?? LocalAuthentication();

  final AppPreferencesStorage _preferencesStorage;
  final LocalAuthentication _localAuthentication;

  static final _pinPattern = RegExp(r'^\d{4}$');

  Future<AppLockConfig> readConfig() => _preferencesStorage.readAppLockConfig();

  Future<void> savePin(String pin, {bool biometricsEnabled = false}) async {
    if (!isValidPin(pin)) {
      throw ArgumentError('PIN must be exactly 4 digits.');
    }

    final salt = _generateSalt();
    await _preferencesStorage.writeAppLockConfig(
      pinHash: _hashPin(pin, salt),
      pinSalt: salt,
      biometricsEnabled: biometricsEnabled,
    );
  }

  Future<bool> validatePin(String pin) async {
    final config = await readConfig();
    if (!config.isEnabled) {
      return false;
    }

    return _hashPin(pin, config.pinSalt!) == config.pinHash;
  }

  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final valid = await validatePin(currentPin);
    if (!valid) {
      return false;
    }

    final config = await readConfig();
    await savePin(newPin, biometricsEnabled: config.biometricsEnabled);
    return true;
  }

  Future<bool> clearPin(String currentPin) async {
    final valid = await validatePin(currentPin);
    if (!valid) {
      return false;
    }

    await _preferencesStorage.clearAppLockConfig();
    return true;
  }

  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _localAuthentication.isDeviceSupported();
      if (!supported) {
        return false;
      }
      final canCheck = await _localAuthentication.canCheckBiometrics;
      if (!canCheck) {
        return false;
      }
      final available = await _localAuthentication.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (e, st) {
      AppLogger.i(
        'Biometric availability check failed',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canUse = await canUseBiometrics();
      if (!canUse) {
        return false;
      }

      return await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to unlock Gulfon Finance',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );
    } catch (e, st) {
      AppLogger.i('Biometric authentication failed', error: e, stackTrace: st);
      return false;
    }
  }

  Future<bool> setBiometricsEnabled(bool enabled) async {
    final config = await readConfig();
    if (!config.isEnabled) {
      return false;
    }

    if (enabled && !await canUseBiometrics()) {
      return false;
    }

    await _preferencesStorage.writeAppLockConfig(
      pinHash: config.pinHash!,
      pinSalt: config.pinSalt!,
      biometricsEnabled: enabled,
    );
    return true;
  }

  bool isValidPin(String pin) => _pinPattern.hasMatch(pin);

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPin(String pin, String salt) {
    final value = utf8.encode('$salt:$pin');
    return sha256.convert(value).toString();
  }
}
