import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static List<BoxShadow> subtle(Brightness brightness) => [
    BoxShadow(
      color: (brightness == Brightness.dark
              ? AppColors.black
              : AppColors.brandNavy)
          .withValues(alpha: brightness == Brightness.dark ? 0.18 : 0.035),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> elevated(Brightness brightness) => [
    BoxShadow(
      color: (brightness == Brightness.dark
              ? AppColors.black
              : AppColors.brandNavy)
          .withValues(alpha: brightness == Brightness.dark ? 0.24 : 0.07),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}
