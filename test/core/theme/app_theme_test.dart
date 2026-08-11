import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/core/theme/app_breakpoints.dart';
import 'package:socialflow_ai/core/theme/app_colors.dart';
import 'package:socialflow_ai/core/theme/app_radius.dart';
import 'package:socialflow_ai/core/theme/app_sizes.dart';
import 'package:socialflow_ai/core/theme/app_spacing.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/core/theme/app_typography.dart';

void main() {
  test('light and dark themes expose the official brand and brightness', () {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.light.colorScheme.primary, AppColors.brandPrimary);
    expect(AppTheme.dark.colorScheme.primary, AppColors.brandPrimary);
    expect(AppTheme.light.scaffoldBackgroundColor, AppColors.lightBackground);
    expect(AppTheme.dark.scaffoldBackgroundColor, AppColors.darkBackground);
  });

  test('interactive theme controls meet the minimum touch target', () {
    final filledSize = AppTheme.light.filledButtonTheme.style?.minimumSize
        ?.resolve(<WidgetState>{});
    final iconSize = AppTheme.light.iconButtonTheme.style?.minimumSize?.resolve(
      <WidgetState>{},
    );

    expect(
      filledSize?.height,
      greaterThanOrEqualTo(AppSizes.minimumTouchTarget),
    );
    expect(iconSize?.height, greaterThanOrEqualTo(AppSizes.minimumTouchTarget));
    expect(iconSize?.width, greaterThanOrEqualTo(AppSizes.minimumTouchTarget));
  });

  test('spacing and breakpoint tokens form a mobile-first scale', () {
    expect(AppSpacing.xs, lessThan(AppSpacing.sm));
    expect(AppSpacing.sm, lessThan(AppSpacing.lg));
    expect(AppBreakpoints.isCompact(320), isTrue);
    expect(AppBreakpoints.isMedium(700), isTrue);
    expect(AppBreakpoints.isExpanded(900), isTrue);
  });

  test('density tokens remain compact without shrinking touch targets', () {
    expect(AppSpacing.cardPadding, lessThan(AppSpacing.lg));
    expect(AppSpacing.sectionGap, lessThan(AppSpacing.xl));
    expect(
      AppSizes.navigationBarHeight,
      greaterThanOrEqualTo(AppSizes.minimumTouchTarget),
    );
    expect(AppRadius.sm, lessThan(AppRadius.card.topLeft.x));
    expect(AppRadius.card.topLeft.x, lessThan(AppRadius.modal.topLeft.x));
  });

  test('typography keeps a clear page section item hierarchy', () {
    expect(
      AppTypography.textTheme.headlineLarge!.fontSize,
      greaterThan(AppTypography.textTheme.headlineMedium!.fontSize!),
    );
    expect(
      AppTypography.textTheme.headlineMedium!.fontSize,
      greaterThan(AppTypography.textTheme.titleMedium!.fontSize!),
    );
    expect(AppTypography.textTheme.titleSmall!.fontWeight, FontWeight.w600);
    expect(
      AppTypography.textTheme.bodySmall!.fontSize,
      lessThan(AppTypography.textTheme.bodyMedium!.fontSize!),
    );
  });
}
