/// Abstract interface for phone call operations.
///
/// Provides two call modes:
/// - [dialNumber] opens the native dialer with the number pre-filled
///   (Android ACTION_DIAL — no permission required).
/// - [callNumber] directly places a call (Android ACTION_CALL —
///   requires CALL_PHONE permission).
///
/// Call logging is NOT handled here — it is the responsibility of
/// the provider layer.
abstract class DialerService {
  /// Launches the Android dialer with [phoneNumber] pre-filled
  /// (ACTION_DIAL). Returns `true` when the dialer opens successfully.
  Future<bool> dialNumber(String phoneNumber);

  /// Directly places a call to [phoneNumber] (ACTION_CALL).
  /// Requires CALL_PHONE permission. Returns `true` on success.
  Future<bool> callNumber(String phoneNumber);

  /// Returns `true` when the CALL_PHONE permission is currently
  /// granted.
  Future<bool> hasCallPermission();

  /// Requests the CALL_PHONE permission from the user.
  /// Returns `true` when the permission is granted.
  Future<bool> requestCallPermission();
}
