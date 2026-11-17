import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';

import '../models/call_history_entry.dart';
import '../models/category_model.dart';
import '../models/contact_model.dart';
import '../services/auth_service.dart';
import '../services/auth_service_impl.dart';
import '../services/call_service.dart';
import '../services/call_service_impl.dart';
import '../services/hive_storage_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

/// Provides the singleton [StorageService] backed by Hive boxes.
///
/// Boxes must be opened before the provider is first read (typically
/// in `main()` before `runApp`).
final storageServiceProvider = Provider<StorageService>((ref) {
  return HiveStorageService(
    contactBox: Hive.box<ContactModel>(HiveBoxes.contacts),
    callHistoryBox: Hive.box<CallHistoryEntry>(HiveBoxes.callHistory),
    categoryBox: Hive.box<CategoryModel>(HiveBoxes.categories),
    settingsBox: Hive.box<dynamic>(HiveBoxes.settings),
  );
});

/// Provides the singleton [DialerService] for initiating phone calls.
final dialerServiceProvider = Provider<DialerService>((ref) {
  return CallServiceImpl();
});

/// Provides the singleton [AuthService] for PIN and biometric auth.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthServiceImpl(
    storageService: ref.read(storageServiceProvider),
    localAuth: LocalAuthentication(),
  );
});
