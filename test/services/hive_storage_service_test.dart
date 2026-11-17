import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:masked_contact_dialer/models/call_history_entry.dart';
import 'package:masked_contact_dialer/models/category_model.dart';
import 'package:masked_contact_dialer/models/contact_model.dart';
import 'package:masked_contact_dialer/services/hive_storage_service.dart';
import 'package:masked_contact_dialer/utils/constants.dart';

import 'dart:io';

void main() {
  late HiveStorageService service;
  late Box<ContactModel> contactBox;
  late Box<CallHistoryEntry> callHistoryBox;
  late Box<CategoryModel> categoryBox;
  late Box<dynamic> settingsBox;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
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

    service = HiveStorageService(
      contactBox: contactBox,
      callHistoryBox: callHistoryBox,
      categoryBox: categoryBox,
      settingsBox: settingsBox,
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

  ContactModel _makeContact({
    String id = '1',
    String displayName = 'Alice',
    String displayNumber = '111',
    String realNumber = '999',
    bool isFavorite = false,
    bool isHidden = false,
    String? category,
  }) {
    final now = DateTime.now();
    return ContactModel(
      id: id,
      displayName: displayName,
      displayNumber: displayNumber,
      realNumber: realNumber,
      isFavorite: isFavorite,
      isHidden: isHidden,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
  }

  // ── Contact CRUD ──────────────────────────────────────────────

  group('Contact CRUD', () {
    test('addContact and getContact round-trip', () async {
      final contact = _makeContact();
      await service.addContact(contact);

      final retrieved = service.getContact('1');
      expect(retrieved, isNotNull);
      expect(retrieved!.displayName, 'Alice');
      expect(retrieved.realNumber, '999');
    });

    test('getContact returns null for missing id', () {
      expect(service.getContact('nonexistent'), isNull);
    });

    test('updateContact replaces existing contact', () async {
      final contact = _makeContact();
      await service.addContact(contact);

      final updated = contact.copyWith(displayName: 'Bob');
      await service.updateContact(updated);

      expect(service.getContact('1')!.displayName, 'Bob');
    });

    test('deleteContact removes the contact', () async {
      await service.addContact(_makeContact());
      await service.deleteContact('1');

      expect(service.getContact('1'), isNull);
      expect(service.getAllContacts(), isEmpty);
    });

    test('getAllContacts returns every contact', () async {
      await service.addContact(_makeContact(id: 'a'));
      await service.addContact(_makeContact(id: 'b'));

      expect(service.getAllContacts(), hasLength(2));
    });
  });

  // ── Filtered contact queries ──────────────────────────────────

  group('Filtered contact queries', () {
    test('getVisibleContacts excludes hidden', () async {
      await service.addContact(_makeContact(id: '1', isHidden: false));
      await service.addContact(_makeContact(id: '2', isHidden: true));

      final visible = service.getVisibleContacts();
      expect(visible, hasLength(1));
      expect(visible.first.id, '1');
    });

    test('getHiddenContacts returns only hidden', () async {
      await service.addContact(_makeContact(id: '1', isHidden: false));
      await service.addContact(_makeContact(id: '2', isHidden: true));

      final hidden = service.getHiddenContacts();
      expect(hidden, hasLength(1));
      expect(hidden.first.id, '2');
    });

    test('getFavoriteContacts returns only favorites', () async {
      await service.addContact(_makeContact(id: '1', isFavorite: true));
      await service.addContact(_makeContact(id: '2', isFavorite: false));

      final favs = service.getFavoriteContacts();
      expect(favs, hasLength(1));
      expect(favs.first.id, '1');
    });

    test('getContactsByCategory returns matching contacts', () async {
      await service.addContact(_makeContact(id: '1', category: 'Work'));
      await service.addContact(_makeContact(id: '2', category: 'Family'));
      await service.addContact(_makeContact(id: '3', category: 'Work'));

      final work = service.getContactsByCategory('Work');
      expect(work, hasLength(2));
      expect(work.every((c) => c.category == 'Work'), isTrue);
    });

    test('getContactsByCategory returns empty for no matches', () async {
      await service.addContact(_makeContact(id: '1', category: 'Work'));

      expect(service.getContactsByCategory('Family'), isEmpty);
    });
  });

  // ── Categories ────────────────────────────────────────────────

  group('Category management', () {
    test('addCategory and getAllCategories', () async {
      await service.addCategory('Work');
      await service.addCategory('Family');

      final cats = service.getAllCategories();
      expect(cats, containsAll(['Work', 'Family']));
      expect(cats, hasLength(2));
    });

    test('deleteCategory removes it', () async {
      await service.addCategory('Work');
      await service.deleteCategory('Work');

      expect(service.getAllCategories(), isEmpty);
    });
  });

  // ── Call History ──────────────────────────────────────────────

  group('Call history', () {
    CallHistoryEntry _makeEntry({
      required String id,
      String contactId = 'c1',
      required DateTime timestamp,
    }) {
      return CallHistoryEntry(
        id: id,
        contactId: contactId,
        timestamp: timestamp,
        callMode: CallModes.actionDial,
      );
    }

    test('logCall and getCallHistory round-trip', () async {
      final entry = _makeEntry(id: '1', timestamp: DateTime(2024, 1, 1));
      await service.logCall(entry);

      final history = service.getCallHistory();
      expect(history, hasLength(1));
      expect(history.first.id, '1');
    });

    test('getCallHistory returns entries sorted descending', () async {
      await service.logCall(
          _makeEntry(id: '1', timestamp: DateTime(2024, 1, 1)));
      await service.logCall(
          _makeEntry(id: '2', timestamp: DateTime(2024, 6, 1)));
      await service.logCall(
          _makeEntry(id: '3', timestamp: DateTime(2024, 3, 1)));

      final history = service.getCallHistory();
      expect(history[0].id, '2'); // June (most recent)
      expect(history[1].id, '3'); // March
      expect(history[2].id, '1'); // January
    });

    test('clearCallHistory removes all entries', () async {
      await service.logCall(
          _makeEntry(id: '1', timestamp: DateTime(2024, 1, 1)));
      await service.logCall(
          _makeEntry(id: '2', timestamp: DateTime(2024, 2, 1)));

      await service.clearCallHistory();
      expect(service.getCallHistory(), isEmpty);
    });

    test('getCallCount returns count for specific contact', () async {
      await service.logCall(_makeEntry(
          id: '1', contactId: 'c1', timestamp: DateTime(2024, 1, 1)));
      await service.logCall(_makeEntry(
          id: '2', contactId: 'c1', timestamp: DateTime(2024, 2, 1)));
      await service.logCall(_makeEntry(
          id: '3', contactId: 'c2', timestamp: DateTime(2024, 3, 1)));

      expect(service.getCallCount('c1'), 2);
      expect(service.getCallCount('c2'), 1);
      expect(service.getCallCount('c3'), 0);
    });
  });

  // ── Settings ──────────────────────────────────────────────────

  group('Settings persistence', () {
    test('saveSetting and getSetting round-trip for String', () async {
      await service.saveSetting('theme', 'dark');
      expect(service.getSetting<String>('theme'), 'dark');
    });

    test('saveSetting and getSetting round-trip for bool', () async {
      await service.saveSetting(SettingsKeys.appLockEnabled, true);
      expect(service.getSetting<bool>(SettingsKeys.appLockEnabled), isTrue);
    });

    test('getSetting returns null for missing key', () {
      expect(service.getSetting<String>('nonexistent'), isNull);
    });

    test('getSetting returns null for type mismatch', () async {
      await service.saveSetting('count', 42);
      expect(service.getSetting<String>('count'), isNull);
    });

    test('saveSetting overwrites previous value', () async {
      await service.saveSetting('key', 'first');
      await service.saveSetting('key', 'second');
      expect(service.getSetting<String>('key'), 'second');
    });
  });
}
