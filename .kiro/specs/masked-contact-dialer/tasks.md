# Implementation Tasks: Masked Contact Dialer

## Task 1: Project Setup and Dependencies

- [x] 1.1 Initialize Flutter project structure with the folder layout: `lib/main.dart`, `lib/models/`, `lib/screens/`, `lib/services/`, `lib/widgets/`, `lib/utils/`
- [x] 1.2 Add dependencies to `pubspec.yaml`: `hive`, `hive_flutter`, `hive_generator`, `build_runner`, `url_launcher`, `local_auth`, `flutter_riverpod`, `uuid`, `crypto` (for SHA-256), `path_provider`
- [x] 1.3 Add dev dependencies: `flutter_test`, `glados` (property-based testing), `mocktail`
- [x] 1.4 Configure Android permissions in `AndroidManifest.xml`: `CALL_PHONE`, `USE_BIOMETRIC`
- [x] 1.5 Create `lib/utils/constants.dart` with Hive box names, type IDs, settings keys, and app-wide constants
- [x] 1.6 Create `lib/utils/themes.dart` with Material 3 theme configuration including dynamic color theming, rounded card shapes, and ripple animations

## Task 2: Data Models

- [x] 2.1 Create `lib/models/contact_model.dart` with `ContactModel` HiveObject class containing all fields (id, displayName, displayNumber, realNumber, imagePath, notes, tags, category, isFavorite, isHidden, isPinned, createdAt, updatedAt) and Hive type adapter annotations
- [x] 2.2 Create `lib/models/call_history_entry.dart` with `CallHistoryEntry` HiveObject class containing id, contactId, timestamp, callMode fields and Hive type adapter annotations
- [x] 2.3 Create `lib/models/category_model.dart` with `CategoryModel` HiveObject class containing name and createdAt fields and Hive type adapter annotations
- [x] 2.4 Run `build_runner` to generate Hive type adapters for all models
- [x] 2.5 Create `lib/models/contact_validator.dart` with validation logic: required displayName (non-empty after trim), required realNumber (non-empty after trim), displayNumber defaults to realNumber when empty, phone format validation

## Task 3: Storage Service

- [x] 3.1 Create `lib/services/storage_service.dart` with the abstract `StorageService` interface defining all CRUD methods for contacts, categories, call history, and settings
- [x] 3.2 Create `lib/services/hive_storage_service.dart` implementing `StorageService` with Hive boxes: contact CRUD (add, update, delete, get, getAll, getVisible, getHidden, getFavorites, getByCategory)
- [x] 3.3 Implement category management in `HiveStorageService`: addCategory, deleteCategory, getAllCategories
- [x] 3.4 Implement call history methods in `HiveStorageService`: logCall, getCallHistory (sorted descending by timestamp), clearCallHistory, getCallCount
- [x] 3.5 Implement settings persistence in `HiveStorageService`: saveSetting, getSetting with generic type support
- [x] 3.6 Initialize Hive in `lib/main.dart`: call `Hive.initFlutter()`, register all type adapters, open all boxes before `runApp`

## Task 4: Authentication Service

- [x] 4.1 Create `lib/services/auth_service.dart` with the abstract `AuthService` interface
- [x] 4.2 Create `lib/services/auth_service_impl.dart` implementing `AuthService`: PIN storage as SHA-256 hash, verifyPin comparing hashes, setPin hashing and storing, isAppLockEnabled reading from settings
- [x] 4.3 Implement hidden section PIN in `AuthServiceImpl`: verifyHiddenPin, setHiddenPin using separate settings key
- [x] 4.4 Implement biometric methods in `AuthServiceImpl`: isBiometricAvailable (via local_auth), authenticateWithBiometrics, isBiometricEnabled reading from settings

## Task 5: Dialer Service

- [x] 5.1 Create `lib/services/call_service.dart` with the abstract `DialerService` interface
- [x] 5.2 Create `lib/services/call_service_impl.dart` implementing `DialerService`: dialNumber using `url_launcher` with `tel:` scheme and `LaunchMode.externalApplication`, callNumber using `tel:` scheme with direct call intent
- [x] 5.3 Implement permission handling in `CallServiceImpl`: hasCallPermission, requestCallPermission
- [x] 5.4 Implement call initiation logic that always uses realNumber, logs the call via StorageService, and handles ACTION_DIAL vs ACTION_CALL modes with fallback

## Task 6: Riverpod Providers

- [x] 6.1 Create `lib/providers/service_providers.dart` with Riverpod providers for StorageService, DialerService, and AuthService instances
- [x] 6.2 Create `lib/providers/contact_provider.dart` with `ContactNotifier` StateNotifier managing contact list state: load, add, update, delete, toggleFavorite, togglePinned, hide, unhide operations
- [x] 6.3 Create `lib/providers/auth_provider.dart` with `AuthNotifier` StateNotifier managing auth state: isAuthenticated, verifyPin, verifyHiddenPin, authenticateWithBiometrics
- [x] 6.4 Create `lib/providers/call_history_provider.dart` with `CallHistoryNotifier` StateNotifier managing call history state: load, logCall, clearHistory, getCallCount
- [x] 6.5 Create `lib/providers/filter_providers.dart` with search query, category filter, favorites-only, and sort mode state providers, plus a derived `filteredContactsProvider` that applies filtering and sorting logic (pinned first, then favorites, then alphabetical)

## Task 7: Reusable Widgets

- [x] 7.1 Create `lib/widgets/contact_tile.dart` with `ContactTile` widget displaying displayName, displayNumber, profile image or GradientAvatar, favorite star indicator, and call button. Must NOT expose realNumber.
- [x] 7.2 Create `lib/widgets/gradient_avatar.dart` with `GradientAvatar` widget that generates a colored circular avatar from the contact's displayName hash
- [x] 7.3 Create `lib/widgets/custom_button.dart` with `CustomButton` Material 3 styled button with ripple and configurable elevation
- [x] 7.4 Create `lib/widgets/search_bar.dart` with `ContactSearchBar` widget providing text input with debounced real-time filtering via the search query provider
- [x] 7.5 Create `lib/widgets/confirmation_dialog.dart` with reusable `ConfirmationDialog` widget for delete, clear history, and call confirmation actions
- [x] 7.6 Create `lib/widgets/pin_entry_widget.dart` with `PinEntryWidget` numeric keypad with dot indicators for PIN input

## Task 8: Authentication Screens

- [ ] 8.1 Create `lib/screens/auth_screen.dart` with PIN entry screen: PinEntryWidget, error message display on incorrect PIN, biometric button when enabled and available
- [ ] 8.2 Create `lib/screens/pin_setup_screen.dart` with first-time PIN creation flow: enter PIN (min 4 digits), confirm PIN, save via AuthService
- [ ] 8.3 Implement app lock gate in `lib/main.dart` or a wrapper widget: if app lock enabled, show AuthScreen before HomeScreen; on successful auth, navigate to HomeScreen

## Task 9: Home Screen

- [ ] 9.1 Create `lib/screens/home_screen.dart` with scaffold, app bar, FAB for adding contacts, and Contact_List displaying ContactTile widgets from filteredContactsProvider
- [ ] 9.2 Implement quick access panel at the top of HomeScreen showing favorited and recently called contacts
- [ ] 9.3 Implement category filter chips or dropdown on HomeScreen that updates categoryFilterProvider
- [ ] 9.4 Implement navigation: FAB → AddContactScreen, ContactTile tap → DetailScreen, app bar menu → SettingsScreen, search icon → SearchPage

## Task 10: Add/Edit Contact Screen

- [ ] 10.1 Create `lib/screens/add_contact_screen.dart` with form fields: displayName (required), displayNumber, realNumber (required), notes, tags input, category dropdown, profile image picker
- [ ] 10.2 Implement form validation using ContactValidator: show inline errors for empty displayName and realNumber, auto-fill displayNumber with realNumber when empty on save
- [ ] 10.3 Implement save logic: create new ContactModel with UUID, persist via ContactProvider, navigate back to HomeScreen
- [ ] 10.4 Implement edit mode: accept existing ContactModel, pre-populate all fields, update via ContactProvider on save

## Task 11: Contact Detail Screen

- [ ] 11.1 Create `lib/screens/detail_screen.dart` displaying all contact fields: displayName, displayNumber, realNumber, profile image, notes, tags, category
- [ ] 11.2 Add call button on DetailScreen that initiates call via DialerService using the configured call mode and the contact's realNumber
- [ ] 11.3 Add edit button navigating to AddContactScreen in edit mode, and delete button with ConfirmationDialog

## Task 12: Search Page

- [ ] 12.1 Create `lib/screens/search_page.dart` with ContactSearchBar and filtered contact list
- [ ] 12.2 Implement real-time filtering: as user types, update searchQueryProvider, display matching contacts (match against displayName, displayNumber, tags)
- [ ] 12.3 Implement empty state: when no results match, display "No contacts found" message
- [ ] 12.4 Add favorites-only toggle filter and alphabetical sort option

## Task 13: Settings Screen

- [ ] 13.1 Create `lib/screens/settings_screen.dart` with toggle switches for: app lock, biometric unlock, call mode (ACTION_DIAL vs ACTION_CALL), call confirmation, export logs
- [ ] 13.2 Implement app lock toggle: when enabling for first time, navigate to PinSetupScreen; when disabling, require current PIN verification
- [ ] 13.3 Implement biometric toggle: only show when device supports biometrics (check via AuthService), enable/disable biometric unlock setting
- [ ] 13.4 Implement call mode selector: radio buttons or dropdown for ACTION_DIAL vs ACTION_CALL
- [ ] 13.5 Implement hidden section access: button/entry point that prompts for hidden section PIN, navigates to HiddenSectionScreen on success

## Task 14: Hidden Section

- [ ] 14.1 Create `lib/screens/hidden_section_screen.dart` displaying contacts from getHiddenContacts() with call and unhide actions
- [ ] 14.2 Implement hide action on ContactTile or DetailScreen: set isHidden=true, update via ContactProvider, remove from visible list
- [ ] 14.3 Implement unhide action on HiddenSectionScreen: set isHidden=false, update via ContactProvider, restore to visible list
- [ ] 14.4 Implement hidden section PIN setup: prompt for PIN creation on first access, verify PIN on subsequent access
- [ ] 14.5 Implement app preview blur: set `FLAG_SECURE` on the Android activity via a platform channel or Flutter plugin to blur the app in recent apps view

## Task 15: Call History

- [ ] 15.1 Create call history UI section (tab or screen accessible from HomeScreen) displaying CallHistoryEntry list sorted by timestamp descending, showing contact displayName, timestamp, and call mode
- [ ] 15.2 Implement call frequency display: show call count badge or label per contact in the call history view
- [ ] 15.3 Implement clear history action with ConfirmationDialog
- [ ] 15.4 Implement call history export: when export logs setting is enabled, provide an export button that writes Call_History to a text file in local device storage via path_provider

## Task 16: Screen Transitions and Polish

- [ ] 16.1 Add smooth page transition animations between screens using Flutter's `PageRouteBuilder` or `Hero` animations
- [ ] 16.2 Ensure all screens use Material 3 components: rounded cards, dynamic color, ripple effects, proper elevation
- [ ] 16.3 Implement GradientAvatar fallback: wherever a contact image is displayed, check imagePath validity and fall back to GradientAvatar if null or file missing

## Task 17: Unit and Property-Based Tests

- [ ] 17.1 Write unit tests for `ContactValidator`: valid contact passes, empty displayName fails, empty realNumber fails, empty displayNumber defaults to realNumber
- [ ] 17.2 Write property-based tests for Properties 1-5 (contact CRUD round-trips, validation, deletion) using `glados` with minimum 100 iterations each
  - [ ] 17.2.1 Property 1: Contact persistence round-trip — generate random valid ContactModel, save and retrieve, verify all fields match
  - [ ] 17.2.2 Property 2: Required field validation — generate contacts with empty displayName or realNumber, verify rejection
  - [ ] 17.2.3 Property 3: Empty displayNumber defaults — generate contacts with empty displayNumber, verify stored displayNumber equals realNumber
  - [ ] 17.2.4 Property 4: Contact update round-trip — generate contact, save, modify fields, update, verify modifications persisted
  - [ ] 17.2.5 Property 5: Contact deletion — generate contacts, delete one, verify not retrievable
- [ ] 17.3 Write property-based tests for Properties 6-8 (category filtering, call routing, real number privacy)
  - [ ] 17.3.1 Property 6: Category filter — generate contacts with various categories, filter by one, verify exact match
  - [ ] 17.3.2 Property 7: Call routing uses realNumber — generate contacts with differing display/real numbers, verify dialer receives realNumber
  - [ ] 17.3.3 Property 8: Real number not exposed in contact list — generate contacts, verify ContactTile data excludes realNumber
- [ ] 17.4 Write property-based tests for Properties 9-11 (sorting and filtering)
  - [ ] 17.4.1 Property 9: Contact list sorting — generate contacts with mixed pinned/favorite/alpha, verify sort order
  - [ ] 17.4.2 Property 10: Search filter — generate contacts and queries, verify filter returns correct matches
  - [ ] 17.4.3 Property 11: Favorites filter — generate contacts with mixed favorite status, verify filter returns only favorites
- [ ] 17.5 Write property-based tests for Properties 12-16 (auth, call history, hidden section)
  - [ ] 17.5.1 Property 12: Incorrect PIN rejection — generate random PINs differing from stored, verify all rejected
  - [ ] 17.5.2 Property 13: Call history logging round-trip — generate calls, verify history entries match
  - [ ] 17.5.3 Property 14: Call history chronological sort — generate entries with random timestamps, verify descending order
  - [ ] 17.5.4 Property 15: Call frequency count — generate call entries for contacts, verify counts match
  - [ ] 17.5.5 Property 16: Hide/unhide round-trip — generate contacts, hide/unhide, verify visibility state
- [ ] 17.6 Write unit tests for AuthService: PIN hashing, correct PIN verification, incorrect PIN rejection, hidden PIN verification
- [ ] 17.7 Write unit tests for DialerService: dialNumber called with correct URL scheme, callNumber called with correct URL scheme, permission fallback to ACTION_DIAL

## Task 18: Widget Tests

- [ ] 18.1 Write widget tests for HomeScreen: renders contact list, FAB present, realNumber not displayed, favorites shown at top
- [ ] 18.2 Write widget tests for AddContactScreen: form validation errors shown, successful submission, edit mode pre-population
- [ ] 18.3 Write widget tests for DetailScreen: all fields displayed including realNumber, edit and delete buttons functional
- [ ] 18.4 Write widget tests for AuthScreen: PIN entry, error on wrong PIN, biometric button visibility
- [ ] 18.5 Write widget tests for SearchPage: search filtering, empty state message, favorites toggle
- [ ] 18.6 Write widget tests for SettingsScreen: toggle states, biometric option hidden when unavailable
