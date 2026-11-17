import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import 'service_providers.dart';

/// Immutable authentication state exposed to the UI.
class AuthState {
  final bool isAuthenticated;

  const AuthState({this.isAuthenticated = false});

  AuthState copyWith({bool? isAuthenticated}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState && isAuthenticated == other.isAuthenticated;

  @override
  int get hashCode => isAuthenticated.hashCode;
}

/// Manages authentication state by delegating to [AuthService].
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  /// Verifies the app-lock PIN. Updates [isAuthenticated] on success.
  bool verifyPin(String pin) {
    final result = _authService.verifyPin(pin);
    if (result) {
      state = state.copyWith(isAuthenticated: true);
    }
    return result;
  }

  /// Verifies the hidden-section PIN. Does NOT change the main
  /// [isAuthenticated] flag — hidden section auth is separate.
  bool verifyHiddenPin(String pin) {
    return _authService.verifyHiddenPin(pin);
  }

  /// Attempts biometric authentication. Updates [isAuthenticated]
  /// on success.
  Future<bool> authenticateWithBiometrics() async {
    final result = await _authService.authenticateWithBiometrics();
    if (result) {
      state = state.copyWith(isAuthenticated: true);
    }
    return result;
  }

  /// Resets authentication state (e.g. on app lock).
  void lock() {
    state = const AuthState(isAuthenticated: false);
  }
}

/// Provides the auth state via [AuthNotifier].
final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});
