import 'dart:io';

import 'package:flutter/material.dart';

import '../models/contact_model.dart';
import 'gradient_avatar.dart';

/// Displays a single contact in a list.
///
/// Shows [displayName], [displayNumber], a profile image (or
/// [GradientAvatar] fallback), a favorite star indicator, and a
/// call button. **Never exposes [realNumber].**
class ContactTile extends StatelessWidget {
  /// The contact to display. Only display-safe fields are read.
  final ContactModel contact;

  /// Called when the user taps the call button.
  final VoidCallback? onCall;

  /// Called when the user taps the favorite star.
  final VoidCallback? onToggleFavorite;

  /// Called when the user taps the tile body.
  final VoidCallback? onTap;

  const ContactTile({
    super.key,
    required this.contact,
    this.onCall,
    this.onToggleFavorite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: _buildAvatar(),
        title: Text(
          contact.displayName,
          style: theme.textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          contact.displayNumber,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
                color: contact.isFavorite
                    ? Colors.amber
                    : theme.colorScheme.onSurfaceVariant,
              ),
              tooltip: contact.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              onPressed: onToggleFavorite,
            ),
            IconButton(
              icon: Icon(
                Icons.call,
                color: theme.colorScheme.primary,
              ),
              tooltip: 'Call',
              onPressed: onCall,
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a profile image if available, otherwise a [GradientAvatar].
  Widget _buildAvatar() {
    if (contact.imagePath != null &&
        contact.imagePath!.isNotEmpty &&
        File(contact.imagePath!).existsSync()) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: FileImage(File(contact.imagePath!)),
      );
    }
    return GradientAvatar(displayName: contact.displayName);
  }
}
