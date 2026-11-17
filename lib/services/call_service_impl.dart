import 'package:url_launcher/url_launcher.dart';

import 'call_service.dart';

/// Concrete [DialerService] using the `url_launcher` package.
///
/// Both [dialNumber] and [callNumber] use the `tel:` URI scheme.
/// Because `url_launcher` does not distinguish between ACTION_DIAL
/// and ACTION_CALL at the Dart level, both methods launch the
/// dialer via [LaunchMode.externalApplication]. On Android the OS
/// decides whether to open the dialer or place the call directly
/// based on the granted permissions and the platform behaviour.
///
/// Permission handling ([hasCallPermission] / [requestCallPermission])
/// is simplified: ACTION_DIAL never requires CALL_PHONE, so the
/// methods return `true` by default. A real ACTION_CALL flow would
/// need a platform channel or the `permission_handler` package.
class CallServiceImpl implements DialerService {
  /// Optional override for [launchUrl] to support testing.
  final Future<bool> Function(Uri url, {LaunchMode mode})? launchUrlFn;

  CallServiceImpl({this.launchUrlFn});

  // ── Internal launcher ─────────────────────────────────────────

  Future<bool> _launch(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    try {
      final launcher = launchUrlFn;
      if (launcher != null) {
        return await launcher(uri, mode: LaunchMode.externalApplication);
      }
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  // ── DialerService implementation ──────────────────────────────

  @override
  Future<bool> dialNumber(String phoneNumber) async {
    return _launch(phoneNumber);
  }

  @override
  Future<bool> callNumber(String phoneNumber) async {
    // Attempt direct call; fall back to dial if it fails.
    final success = await _launch(phoneNumber);
    if (!success) {
      return dialNumber(phoneNumber);
    }
    return success;
  }

  @override
  Future<bool> hasCallPermission() async {
    // ACTION_DIAL does not require CALL_PHONE permission.
    // A full implementation would check via platform channels or
    // the permission_handler package.
    return true;
  }

  @override
  Future<bool> requestCallPermission() async {
    // ACTION_DIAL does not require CALL_PHONE permission.
    // A full implementation would request via platform channels or
    // the permission_handler package.
    return true;
  }
}
