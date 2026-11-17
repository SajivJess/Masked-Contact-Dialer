import 'package:hive/hive.dart';
import '../utils/constants.dart';

part 'call_history_entry.g.dart';

/// A record of a call initiated through the app.
///
/// Stores the [contactId] reference, [timestamp], and [callMode]
/// (ACTION_DIAL or ACTION_CALL) for each outgoing call.
@HiveType(typeId: HiveTypeIds.callHistoryEntry)
class CallHistoryEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String contactId;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String callMode;

  CallHistoryEntry({
    required this.id,
    required this.contactId,
    required this.timestamp,
    required this.callMode,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CallHistoryEntry) return false;
    return id == other.id &&
        contactId == other.contactId &&
        timestamp == other.timestamp &&
        callMode == other.callMode;
  }

  @override
  int get hashCode => Object.hash(id, contactId, timestamp, callMode);

  @override
  String toString() =>
      'CallHistoryEntry(id: $id, contactId: $contactId, callMode: $callMode, timestamp: $timestamp)';
}
