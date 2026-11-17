import 'package:flutter/material.dart';

/// A reusable confirmation dialog for destructive or important actions
/// such as delete, clear history, and call confirmation.
///
/// Use the static [show] method for a convenient one-liner that
/// returns `true` when the user confirms and `false` otherwise.
class ConfirmationDialog extends StatelessWidget {
  /// Dialog title.
  final String title;

  /// Descriptive message shown in the dialog body.
  final String message;

  /// Label for the confirm button. Defaults to `'Confirm'`.
  final String confirmLabel;

  /// Label for the cancel button. Defaults to `'Cancel'`.
  final String cancelLabel;

  /// When `true`, the confirm button uses the error colour to
  /// signal a destructive action.
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  /// Shows the dialog and returns `true` when the user taps confirm.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
