/// Result of validating contact fields.
///
/// Contains per-field error messages. A contact is valid when all error
/// fields are `null`.
class ValidationResult {
  final String? displayNameError;
  final String? realNumberError;
  final String? displayNumberError;

  const ValidationResult({
    this.displayNameError,
    this.realNumberError,
    this.displayNumberError,
  });

  /// Whether the validation passed with no errors.
  bool get isValid =>
      displayNameError == null &&
      realNumberError == null &&
      displayNumberError == null;

  @override
  String toString() =>
      'ValidationResult(isValid: $isValid, displayNameError: $displayNameError, '
      'realNumberError: $realNumberError, displayNumberError: $displayNumberError)';
}

/// Validates contact fields before persistence.
///
/// Rules:
/// - [displayName] is required (non-empty after trim).
/// - [realNumber] is required (non-empty after trim) and must be a valid
///   phone format (digits, `+`, `-`, spaces, parentheses only).
/// - [displayNumber] defaults to [realNumber] when empty/blank.
class ContactValidator {
  ContactValidator._();

  /// Regex allowing digits, `+`, `-`, spaces, and parentheses.
  static final _phoneRegex = RegExp(r'^[0-9+\-\s()]+$');

  /// Validates the given contact fields and returns a [ValidationResult].
  ///
  /// When [displayNumber] is empty or blank it is normalised to [realNumber]
  /// in the returned [normalizedDisplayNumber].
  static ValidationResult validate({
    required String displayName,
    required String realNumber,
    String displayNumber = '',
  }) {
    String? displayNameError;
    String? realNumberError;

    // Display name: required, non-empty after trim.
    if (displayName.trim().isEmpty) {
      displayNameError = 'Display name is required';
    }

    // Real number: required, non-empty after trim, valid phone format.
    final trimmedReal = realNumber.trim();
    if (trimmedReal.isEmpty) {
      realNumberError = 'Real number is required';
    } else if (!_phoneRegex.hasMatch(trimmedReal)) {
      realNumberError =
          'Invalid phone format. Only digits, +, -, spaces, and parentheses are allowed';
    }

    return ValidationResult(
      displayNameError: displayNameError,
      realNumberError: realNumberError,
    );
  }

  /// Returns the effective display number: falls back to [realNumber] when
  /// [displayNumber] is empty or blank.
  static String resolveDisplayNumber({
    required String displayNumber,
    required String realNumber,
  }) {
    return displayNumber.trim().isEmpty ? realNumber : displayNumber;
  }
}
