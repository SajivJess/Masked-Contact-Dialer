import 'package:hive/hive.dart';

import '../models/call_history_entry.dart';
import '../models/category_model.dart';
import '../models/contact_model.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

/// Hive-backed implementation of [StorageService].
///
/// Each data domain maps to its own Hive box:
/// - [HiveBoxes.contacts]    → `ContactModel`
/// - [HiveBoxes.callHistory] → `CallHistoryEntry`
/// - [HiveBoxes.categories]  → `CategoryModel`
/// - [HiveBoxes.settings]    → dynamic key-value pairs
class HiveStorageService implements StorageService {
  final Box<ContactModel> _contactBox;
  final Box<CallHistoryEntry> _callHistoryBox;
  final Box<CategoryModel> _categoryBox;
  final Box<dynamic> _settingsBox;

  HiveStorageService({
    required Box<ContactModel> contactBox,
    required Box<CallHistoryEntry> callHistoryBox,
    required Box<CategoryModel> categoryBox,
    required Box<dynamic> settingsBox,
  })  : _contactBox = contactBox,
        _callHistoryBox = callHistoryBox,
        _categoryBox = categoryBox,
        _settingsBox = settingsBox;

  // ── Contacts ──────────────────────────────────────────────────

  @override
  Future<void> addContact(ContactModel contact) async {
    await _contactBox.put(contact.id, contact);
  }

  @override
  Future<void> updateContact(ContactModel contact) async {
    await _contactBox.put(contact.id, contact);
  }

  @override
  Future<void> deleteContact(String id) async {
    await _contactBox.delete(id);
  }

  @override
  ContactModel? getContact(String id) {
    return _contactBox.get(id);
  }

  @override
  List<ContactModel> getAllContacts() {
    return _contactBox.values.toList();
  }

  @override
  List<ContactModel> getVisibleContacts() {
    return _contactBox.values.where((c) => !c.isHidden).toList();
  }

  @override
  List<ContactModel> getHiddenContacts() {
    return _contactBox.values.where((c) => c.isHidden).toList();
  }

  @override
  List<ContactModel> getFavoriteContacts() {
    return _contactBox.values.where((c) => c.isFavorite).toList();
  }

  @override
  List<ContactModel> getContactsByCategory(String category) {
    return _contactBox.values.where((c) => c.category == category).toList();
  }

  // ── Categories ────────────────────────────────────────────────

  @override
  Future<void> addCategory(String name) async {
    await _categoryBox.put(
      name,
      CategoryModel(name: name, createdAt: DateTime.now()),
    );
  }

  @override
  Future<void> deleteCategory(String name) async {
    await _categoryBox.delete(name);
  }

  @override
  List<String> getAllCategories() {
    return _categoryBox.values.map((c) => c.name).toList();
  }

  // ── Call History ──────────────────────────────────────────────

  @override
  Future<void> logCall(CallHistoryEntry entry) async {
    await _callHistoryBox.put(entry.id, entry);
  }

  @override
  List<CallHistoryEntry> getCallHistory() {
    final entries = _callHistoryBox.values.toList();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  @override
  Future<void> clearCallHistory() async {
    await _callHistoryBox.clear();
  }

  @override
  int getCallCount(String contactId) {
    return _callHistoryBox.values
        .where((e) => e.contactId == contactId)
        .length;
  }

  // ── Settings / Preferences ────────────────────────────────────

  @override
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  @override
  T? getSetting<T>(String key) {
    final value = _settingsBox.get(key);
    if (value is T) return value;
    return null;
  }
}
