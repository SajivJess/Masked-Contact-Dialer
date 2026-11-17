import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contact_model.dart';
import 'contact_provider.dart';

/// Current search query entered by the user.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Currently selected category filter (`null` means show all).
final categoryFilterProvider = StateProvider<String?>((ref) => null);

/// When `true`, only contacts with [isFavorite] are shown.
final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

/// Derived provider that applies search, category, and favorites
/// filters to the contact list, then sorts the result.
///
/// Sort order:
///   1. Pinned contacts first
///   2. Within each pinned/non-pinned group, favorites first
///   3. Within each sub-group, alphabetical by displayName (case-insensitive)
final filteredContactsProvider = Provider<List<ContactModel>>((ref) {
  final contacts = ref.watch(contactProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(categoryFilterProvider);
  final favoritesOnly = ref.watch(showFavoritesOnlyProvider);

  // ── Filter ──────────────────────────────────────────────────

  var filtered = contacts.where((c) {
    // Search filter: match displayName, displayNumber, or any tag.
    if (query.isNotEmpty) {
      final matchesName = c.displayName.toLowerCase().contains(query);
      final matchesNumber = c.displayNumber.toLowerCase().contains(query);
      final matchesTags =
          c.tags.any((tag) => tag.toLowerCase().contains(query));
      if (!matchesName && !matchesNumber && !matchesTags) return false;
    }

    // Category filter.
    if (category != null && c.category != category) return false;

    // Favorites-only filter.
    if (favoritesOnly && !c.isFavorite) return false;

    return true;
  }).toList();

  // ── Sort ────────────────────────────────────────────────────

  filtered.sort((a, b) {
    // 1. Pinned first.
    if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;

    // 2. Favorites first within each pinned group.
    if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;

    // 3. Alphabetical by displayName (case-insensitive).
    return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  });

  return filtered;
});
