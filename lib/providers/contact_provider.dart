import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contact_model.dart';
import '../services/storage_service.dart';
import 'service_providers.dart';

/// Manages the list of visible (non-hidden) contacts.
///
/// All mutations delegate to [StorageService] and then reload the
/// in-memory state so the UI stays in sync with Hive.
class ContactNotifier extends StateNotifier<List<ContactModel>> {
  final StorageService _storageService;

  ContactNotifier(this._storageService) : super([]);

  /// Loads visible contacts from storage into state.
  void load() {
    state = _storageService.getVisibleContacts();
  }

  /// Persists a new contact and reloads state.
  Future<void> add(ContactModel contact) async {
    await _storageService.addContact(contact);
    load();
  }

  /// Updates an existing contact and reloads state.
  Future<void> update(ContactModel contact) async {
    await _storageService.updateContact(contact);
    load();
  }

  /// Deletes a contact by [id] and reloads state.
  Future<void> delete(String id) async {
    await _storageService.deleteContact(id);
    load();
  }

  /// Toggles the [isFavorite] flag, persists, and reloads.
  Future<void> toggleFavorite(String id) async {
    final contact = _storageService.getContact(id);
    if (contact == null) return;
    final updated = contact.copyWith(
      isFavorite: !contact.isFavorite,
      updatedAt: DateTime.now(),
    );
    await _storageService.updateContact(updated);
    load();
  }

  /// Toggles the [isPinned] flag, persists, and reloads.
  Future<void> togglePinned(String id) async {
    final contact = _storageService.getContact(id);
    if (contact == null) return;
    final updated = contact.copyWith(
      isPinned: !contact.isPinned,
      updatedAt: DateTime.now(),
    );
    await _storageService.updateContact(updated);
    load();
  }

  /// Hides a contact (removes from visible list), persists, and reloads.
  Future<void> hide(String id) async {
    final contact = _storageService.getContact(id);
    if (contact == null) return;
    final updated = contact.copyWith(
      isHidden: true,
      updatedAt: DateTime.now(),
    );
    await _storageService.updateContact(updated);
    load();
  }

  /// Unhides a contact (restores to visible list), persists, and reloads.
  Future<void> unhide(String id) async {
    final contact = _storageService.getContact(id);
    if (contact == null) return;
    final updated = contact.copyWith(
      isHidden: false,
      updatedAt: DateTime.now(),
    );
    await _storageService.updateContact(updated);
    load();
  }
}

/// Provides the contact list state via [ContactNotifier].
final contactProvider =
    StateNotifierProvider<ContactNotifier, List<ContactModel>>((ref) {
  final storageService = ref.read(storageServiceProvider);
  return ContactNotifier(storageService);
});
