import 'package:flutter_test/flutter_test.dart';
import 'package:masked_contact_dialer/services/call_service_impl.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  // ── dialNumber ────────────────────────────────────────────────

  group('dialNumber', () {
    test('calls launchUrl with correct tel: URI and external mode',
        () async {
      Uri? capturedUri;
      LaunchMode? capturedMode;

      final service = CallServiceImpl(
        launchUrlFn: (url, {LaunchMode mode = LaunchMode.platformDefault}) {
          capturedUri = url;
          capturedMode = mode;
          return Future.value(true);
        },
      );

      final result = await service.dialNumber('+1234567890');

      expect(result, isTrue);
      expect(capturedUri, Uri.parse('tel:+1234567890'));
      expect(capturedMode, LaunchMode.externalApplication);
    });

    test('returns false when launchUrl fails', () async {
      final service = CallServiceImpl(
        launchUrlFn: (url, {LaunchMode mode = LaunchMode.platformDefault}) {
          return Future.value(false);
        },
      );

      final result = await service.dialNumber('+1234567890');
      expect(result, isFalse);
    });

    test('returns false when launchUrl throws', () async {
      final service = CallServiceImpl(
        launchUrlFn: (url, {LaunchMode mode = LaunchMode.platformDefault}) {
          throw Exception('No dialer app');
        },
      );

      final result = await service.dialNumber('+1234567890');
      expect(result, isFalse);
    });
  });

  // ── callNumber ────────────────────────────────────────────────

  group('callNumber', () {
    test('calls launchUrl with correct tel: URI', () async {
      Uri? capturedUri;

      final service = CallServiceImpl(
        launchUrlFn: (url, {LaunchMode mode = LaunchMode.platformDefault}) {
          capturedUri = url;
          return Future.value(true);
        },
      );

      final result = await service.callNumber('5551234');

      expect(result, isTrue);
      expect(capturedUri, Uri.parse('tel:5551234'));
    });

    test('falls back to dialNumber when initial launch fails', () async {
      int callCount = 0;

      final service = CallServiceImpl(
        launchUrlFn: (url, {LaunchMode mode = LaunchMode.platformDefault}) {
          callCount++;
          // First call fails, second (fallback) succeeds
          if (callCount == 1) return Future.value(false);
          return Future.value(true);
        },
      );

      final result = await service.callNumber('5551234');

      expect(result, isTrue);
      expect(callCount, 2); // initial attempt + fallback
    });
  });

  // ── Permission handling ───────────────────────────────────────

  group('Permission handling', () {
    test('hasCallPermission returns true (ACTION_DIAL default)', () async {
      final service = CallServiceImpl();
      expect(await service.hasCallPermission(), isTrue);
    });

    test('requestCallPermission returns true (ACTION_DIAL default)',
        () async {
      final service = CallServiceImpl();
      expect(await service.requestCallPermission(), isTrue);
    });
  });

  // ── Phone number formatting ───────────────────────────────────

  group('Phone number formatting in URI', () {
    test('handles numbers with spaces and special characters', () async {
      Uri? capturedUri;

      final service = CallServiceImpl(
        launchUrlFn: (url, {LaunchMode mode = LaunchMode.platformDefault}) {
          capturedUri = url;
          return Future.value(true);
        },
      );

      await service.dialNumber('+1 (555) 123-4567');
      expect(capturedUri.toString(), 'tel:+1%20(555)%20123-4567');
    });
  });
}
