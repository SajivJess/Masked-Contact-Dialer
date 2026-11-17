import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';

import '../utils/constants.dart';
import 'auth_service.dart';
import 'storage_service.dart';

/// Concrete [AuthService] backed by SHA-256 PIN hashing and the
/// `local_auth` package for biometric authentication.
///
/// PIN hashes and preference flags are read from / written to
/// [StorageService] using keys defined in [SettingsKeys].
class AuthServiceImpl implements AuthService {
  final StorageService _storageService;
  final LocalAuthentication _localAuth;

  AuthServiceImpl({
    required StorageService storageService,
    required LocalAuthentication localAuth,
  })  : _storageService = storageService,
        _localAuth = localAuth;

  // ── Helpers ───────────────────────────────────────────────────

  /// Produces the SHA-256 hex digest of [pin].
  static String hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  // ── App-lock PIN ──────────────────────────────────────────────

  @override
  bool isAppLockEnabled() {
    return _storageService.getSetting<bool>(SettingsKeys.appLockEnabled) ??
        false;
  }

  @override
  bool verifyPin(String pin) {
    final storedHash =
        _storageService.getSetting<String>(SettingsKeys.pinHash);
    if (storedHash == null) return false;
    return hashPin(pin) == storedHash;
  }

  @override
  Future<void> setPin(String pin) async {
    await _storageService.saveSetting(SettingsKeys.pinHash, hashPin(pin));
  }

  // ── Hidden-section PIN ────────────────────────────────────────

  @override
  bool verifyHiddenPin(String pin) {
    final storedHash =
        _storageService.getSetting<String>(SettingsKeys.hiddenPinHash);
    if (storedHash == null) return false;
    return hashPin(pin) == storedHash;
  }

  @override
  Future<void> setHiddenPin(String pin) async {
    await _storageService.saveSetting(
        SettingsKeys.hiddenPinHash, hashPin(pin));
  }

  // ── Biometrics ────────────────────────────────────────────────

  @override
  Future<bool> isBiometricAvailable() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    final isSupported = await _localAuth.isDeviceSupported();
    return canCheck && isSupported;
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access ${AppConstants.appName}',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  @override
  bool isBiometricEnabled() {
    return _storageService
            .getSetting<bool>(SettingsKeys.biometricEnabled) ??
        false;
  }
}
