import 'package:flutter/material.dart';

import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_spacing.dart';

abstract final class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      builder:
          (context) => ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.sizeOf(context).height *
                  AppSizes.modalMaxHeightFactor,
              maxWidth: AppSizes.contentMaxWidth,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                title == null ? AppSpacing.sm : AppSpacing.none,
                AppSpacing.xl,
                AppSpacing.xxl + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null) ...[
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Flexible(child: SingleChildScrollView(child: child)),
                ],
              ),
            ),
          ),
    );
  }
}
