import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'app_buttons.dart';

abstract final class AppDialog {
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Annuler',
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actionsPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.none,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            actions: [
              AppTertiaryButton(
                label: cancelLabel,
                onPressed: () => Navigator.pop(context, false),
              ),
              FilledButton(
                style:
                    destructive
                        ? FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                        )
                        : null,
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
    );
  }
}
