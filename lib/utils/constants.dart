/// App-wide constants for the Masked Contact Dialer application.
library;

/// Hive box names used throughout the application.
class HiveBoxes {
  HiveBoxes._();

  static const String contacts = 'contacts';
  static const String callHistory = 'call_history';
  static const String categories = 'categories';
  static const String settings = 'settings';
}

/// Hive type adapter IDs for registered model classes.
class HiveTypeIds {
  HiveTypeIds._();

  static const int contactModel = 0;
  static const int callHistoryEntry = 1;
  static const int categoryModel = 2;
}

/// Keys used in the settings Hive box.
class SettingsKeys {
  SettingsKeys._();

  static const String appLockEnabled = 'app_lock_enabled';
  static const String pinHash = 'pin_hash';
  static const String hiddenPinHash = 'hidden_pin_hash';
  static const String biometricEnabled = 'biometric_enabled';
  static const String callMode = 'call_mode';
  static const String callConfirmEnabled = 'call_confirm_enabled';
  static const String exportLogsEnabled = 'export_logs_enabled';
}

/// Call mode constants matching Android Intent actions.
class CallModes {
  CallModes._();

  static const String actionDial = 'ACTION_DIAL';
  static const String actionCall = 'ACTION_CALL';
}

/// General app-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Masked Contact Dialer';
  static const int minPinLength = 4;
  static const int searchDebounceMs = 300;
}
