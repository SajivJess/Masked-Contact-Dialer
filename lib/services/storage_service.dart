import '../models/call_history_entry.dart';
import '../models/contact_model.dart';

/// Abstract interface for all local data persistence operations.
///
/// Covers CRUD for contacts, categories, call history, and
/// generic key-value settings. Implementations are expected to
/// operate synchronously for reads and asynchronously for writes.
abstract class StorageService {
  // ── Contacts ──────────────────────────────────────────────────

  /// Persists a new contact.
  Future<void> addContact(ContactModel contact);

  /// Replaces the stored contact that shares the same [ContactModel.id].
  Future<void> updateContact(ContactModel contact);

  /// Removes the contact identified by [id].
  Future<void> deleteContact(String id);

  /// Returns the contact for [id], or `null` if not found.
  ContactModel? getContact(String id);

  /// Returns every stored contact regardless of visibility.
  List<ContactModel> getAllContacts();

  /// Returns contacts where [ContactModel.isHidden] is `false`.
  List<ContactModel> getVisibleContacts();

  /// Returns contacts where [ContactModel.isHidden] is `true`.
  List<ContactModel> getHiddenContacts();

  /// Returns contacts where [ContactModel.isFavorite] is `true`.
  List<ContactModel> getFavoriteContacts();

  /// Returns contacts whose [ContactModel.category] equals [category].
  List<ContactModel> getContactsByCategory(String category);

  // ── Categories ────────────────────────────────────────────────

  /// Adds a new category with the given [name].
  Future<void> addCategory(String name);

  /// Removes the category identified by [name].
  Future<void> deleteCategory(String name);

  /// Returns the names of all stored categories.
  List<String> getAllCategories();

  // ── Call History ──────────────────────────────────────────────

  /// Persists a call history entry.
  Future<void> logCall(CallHistoryEntry entry);

  /// Returns all call history entries sorted by timestamp descending.
  List<CallHistoryEntry> getCallHistory();

  /// Removes every call history entry.
  Future<void> clearCallHistory();

  /// Returns the number of call history entries for [contactId].
  int getCallCount(String contactId);

  // ── Settings / Preferences ────────────────────────────────────

  /// Stores a setting [value] under [key].
  Future<void> saveSetting(String key, dynamic value);

  /// Retrieves the setting stored under [key], cast to [T].
  /// Returns `null` when the key does not exist.
  T? getSetting<T>(String key);
}
