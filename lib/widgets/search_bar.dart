import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/filter_providers.dart';
import '../utils/constants.dart';

/// A search text field with debounced real-time filtering.
///
/// Updates [searchQueryProvider] after a 300 ms debounce so the
/// contact list re-filters without excessive rebuilds.
class ContactSearchBar extends ConsumerStatefulWidget {
  const ContactSearchBar({super.key});

  @override
  ConsumerState<ContactSearchBar> createState() => _ContactSearchBarState();
}

class _ContactSearchBarState extends ConsumerState<ContactSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        ref.read(searchQueryProvider.notifier).state = value;
      },
    );
  }

  void _onClear() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      decoration: InputDecoration(
        hintText: 'Search contacts…',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _onClear,
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
