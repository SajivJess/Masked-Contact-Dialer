import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'package:masked_contact_dialer/models/call_history_entry.dart';
import 'package:masked_contact_dialer/models/category_model.dart';
import 'package:masked_contact_dialer/models/contact_model.dart';
import 'package:masked_contact_dialer/services/auth_service_impl.dart';
import 'package:masked_contact_dialer/services/hive_storage_service.dart';
import 'package:masked_contact_dialer/utils/constants.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  late HiveStorageService storageService;
  late MockLocalAuthentication mockLocalAuth;
  late AuthServiceImpl authService;
  late Directory tempDir;

  late Box<ContactModel> contactBox;
  late Box<CallHistoryEntry> callHistoryBox;
  late Box<CategoryModel> categoryBox;
  late Box<dynamic> settingsBox;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('auth_test_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(HiveTypeIds.contactModel)) {
      Hive.registerAdapter(ContactModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.callHistoryEntry)) {
      Hive.registerAdapter(CallHistoryEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.categoryModel)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }

    contactBox = await Hive.openBox<ContactModel>(HiveBoxes.contacts);
    callHistoryBox =
        await Hive.openBox<CallHistoryEntry>(HiveBoxes.callHistory);
    categoryBox = await Hive.openBox<CategoryModel>(HiveBoxes.categories);
    settingsBox = await Hive.openBox<dynamic>(HiveBoxes.settings);

    storageService = HiveStorageService(
      contactBox: contactBox,
      callHistoryBox: callHistoryBox,
      categoryBox: categoryBox,
      settingsBox: settingsBox,
    );

    mockLocalAuth = MockLocalAuthentication();
    authService = AuthServiceImpl(
      storageService: storageService,
      localAuth: mockLocalAuth,
    );
  });

  tearDown(() async {
    await contactBox.close();
    await callHistoryBox.close();
    await categoryBox.close();
    await settingsBox.close();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  // ── PIN hashing ───────────────────────────────────────────────

  group('PIN hashing', () {
    test('hashPin produces consistent SHA-256 hex digest', () {
      final hash1 = AuthServiceImpl.hashPin('1234');
      final hash2 = AuthServiceImpl.hashPin('1234');
      expect(hash1, hash2);
      // SHA-256 produces a 64-character hex string
      expect(hash1.length, 64);
    });

    test('hashPin produces different hashes for different PINs', () {
      final hash1 = AuthServiceImpl.hashPin('1234');
      final hash2 = AuthServiceImpl.hashPin('5678');
      expect(hash1, isNot(hash2));
    });
  });

  // ── App-lock PIN ──────────────────────────────────────────────

  group('App-lock PIN', () {
    test('setPin stores hash and verifyPin returns true for correct PIN',
        () async {
      await authService.setPin('1234');
      expect(authService.verifyPin('1234'), isTrue);
    });

    test('verifyPin returns false for incorrect PIN', () async {
      await authService.setPin('1234');
      expect(authService.verifyPin('0000'), isFalse);
      expect(authService.verifyPin('1235'), isFalse);
    });

    test('verifyPin returns false when no PIN is set', () {
      expect(authService.verifyPin('1234'), isFalse);
    });

    test('setPin overwrites previous PIN', () async {
      await authService.setPin('1234');
      await authService.setPin('5678');
      expect(authService.verifyPin('1234'), isFalse);
      expect(authService.verifyPin('5678'), isTrue);
    });
  });

  // ── Hidden-section PIN ────────────────────────────────────────

  group('Hidden-section PIN', () {
    test('setHiddenPin stores hash and verifyHiddenPin returns true',
        () async {
      await authService.setHiddenPin('9999');
      expect(authService.verifyHiddenPin('9999'), isTrue);
    });

    test('verifyHiddenPin returns false for incorrect PIN', () async {
      await authService.setHiddenPin('9999');
      expect(authService.verifyHiddenPin('0000'), isFalse);
    });

    test('verifyHiddenPin returns false when no hidden PIN is set', () {
      expect(authService.verifyHiddenPin('9999'), isFalse);
    });

    test('hidden PIN is independent of app-lock PIN', () async {
      await authService.setPin('1234');
      await authService.setHiddenPin('5678');

      expect(authService.verifyPin('1234'), isTrue);
      expect(authService.verifyPin('5678'), isFalse);
      expect(authService.verifyHiddenPin('5678'), isTrue);
      expect(authService.verifyHiddenPin('1234'), isFalse);
    });
  });

  // ── App lock enabled ──────────────────────────────────────────

  group('isAppLockEnabled', () {
    test('returns false when setting is not set', () {
      expect(authService.isAppLockEnabled(), isFalse);
    });

    test('returns true when setting is enabled', () async {
      await storageService.saveSetting(SettingsKeys.appLockEnabled, true);
      expect(authService.isAppLockEnabled(), isTrue);
    });

    test('returns false when setting is disabled', () async {
      await storageService.saveSetting(SettingsKeys.appLockEnabled, false);
      expect(authService.isAppLockEnabled(), isFalse);
    });
  });

  // ── Biometric enabled ─────────────────────────────────────────

  group('isBiometricEnabled', () {
    test('returns false when setting is not set', () {
      expect(authService.isBiometricEnabled(), isFalse);
    });

    test('returns true when setting is enabled', () async {
      await storageService.saveSetting(SettingsKeys.biometricEnabled, true);
      expect(authService.isBiometricEnabled(), isTrue);
    });
  });

  // ── Biometric availability ────────────────────────────────────

  group('isBiometricAvailable', () {
    test('returns true when both checks pass', () async {
      when(() => mockLocalAuth.canCheckBiometrics)
          .thenAnswer((_) async => true);
      when(() => mockLocalAuth.isDeviceSupported())
          .thenAnswer((_) async => true);

      expect(await authService.isBiometricAvailable(), isTrue);
    });

    test('returns false when canCheckBiometrics is false', () async {
      when(() => mockLocalAuth.canCheckBiometrics)
          .thenAnswer((_) async => false);
      when(() => mockLocalAuth.isDeviceSupported())
          .thenAnswer((_) async => true);

      expect(await authService.isBiometricAvailable(), isFalse);
    });

    test('returns false when isDeviceSupported is false', () async {
      when(() => mockLocalAuth.canCheckBiometrics)
          .thenAnswer((_) async => true);
      when(() => mockLocalAuth.isDeviceSupported())
          .thenAnswer((_) async => false);

      expect(await authService.isBiometricAvailable(), isFalse);
    });
  });

  // ── Biometric authentication ──────────────────────────────────

  group('authenticateWithBiometrics', () {
    test('returns true on successful authentication', () async {
      when(() => mockLocalAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => true);

      expect(await authService.authenticateWithBiometrics(), isTrue);
    });

    test('returns false on failed authentication', () async {
      when(() => mockLocalAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => false);

      expect(await authService.authenticateWithBiometrics(), isFalse);
    });

    test('returns false when authenticate throws', () async {
      when(() => mockLocalAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenThrow(Exception('Biometric error'));

      expect(await authService.authenticateWithBiometrics(), isFalse);
    });
  });
}
