/// Abstract interface for authentication operations.
///
/// Covers app-lock PIN verification, hidden-section PIN verification,
/// and biometric authentication. Implementations are expected to
/// store PIN hashes (never plaintext) via [StorageService].
abstract class AuthService {
  /// Returns `true` when the user has enabled app lock in settings.
  bool isAppLockEnabled();

  /// Returns `true` when biometric authentication hardware is
  /// available and the device supports it.
  Future<bool> isBiometricAvailable();

  /// Compares the SHA-256 hash of [pin] against the stored app-lock
  /// PIN hash. Returns `true` on match.
  bool verifyPin(String pin);

  /// Hashes [pin] with SHA-256 and persists the result as the
  /// app-lock PIN.
  Future<void> setPin(String pin);

  /// Compares the SHA-256 hash of [pin] against the stored
  /// hidden-section PIN hash. Returns `true` on match.
  bool verifyHiddenPin(String pin);

  /// Hashes [pin] with SHA-256 and persists the result as the
  /// hidden-section PIN.
  Future<void> setHiddenPin(String pin);

  /// Triggers the device biometric prompt and returns `true` when
  /// the user authenticates successfully.
  Future<bool> authenticateWithBiometrics();

  /// Returns `true` when the user has enabled biometric unlock
  /// in settings.
  bool isBiometricEnabled();
}
