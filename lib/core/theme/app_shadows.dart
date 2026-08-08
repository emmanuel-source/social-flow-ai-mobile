import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static List<BoxShadow> subtle(Brightness brightness) => [
    BoxShadow(
      color: (brightness == Brightness.dark
              ? AppColors.black
              : AppColors.brandNavy)
          .withValues(alpha: brightness == Brightness.dark ? 0.24 : 0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> elevated(Brightness brightness) => [
    BoxShadow(
      color: (brightness == Brightness.dark
              ? AppColors.black
              : AppColors.brandNavy)
          .withValues(alpha: brightness == Brightness.dark ? 0.32 : 0.12),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
  ];
}
