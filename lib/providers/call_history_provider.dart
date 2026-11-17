import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/call_history_entry.dart';
import '../services/storage_service.dart';
import 'service_providers.dart';

/// Manages call history state by delegating to [StorageService].
class CallHistoryNotifier extends StateNotifier<List<CallHistoryEntry>> {
  final StorageService _storageService;
  static const _uuid = Uuid();

  CallHistoryNotifier(this._storageService) : super([]);

  /// Loads call history from storage (sorted most-recent-first).
  void load() {
    state = _storageService.getCallHistory();
  }

  /// Creates a new [CallHistoryEntry], persists it, and reloads state.
  Future<void> logCall({
    required String contactId,
    required String callMode,
  }) async {
    final entry = CallHistoryEntry(
      id: _uuid.v4(),
      contactId: contactId,
      timestamp: DateTime.now(),
      callMode: callMode,
    );
    await _storageService.logCall(entry);
    load();
  }

  /// Removes all call history entries and reloads state.
  Future<void> clearHistory() async {
    await _storageService.clearCallHistory();
    load();
  }

  /// Returns the number of calls logged for [contactId].
  int getCallCount(String contactId) {
    return _storageService.getCallCount(contactId);
  }
}

/// Provides the call history state via [CallHistoryNotifier].
final callHistoryProvider =
    StateNotifierProvider<CallHistoryNotifier, List<CallHistoryEntry>>((ref) {
  final storageService = ref.read(storageServiceProvider);
  return CallHistoryNotifier(storageService);
});
