import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppGradients {
  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.brandSecondary,
      AppColors.brandPrimary,
      AppColors.brandBlue,
    ],
  );

  static const ai = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.brandNavy,
      AppColors.brandSecondary,
      AppColors.brandBlue,
    ],
  );

  static LinearGradient subtle(Brightness brightness) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors:
        brightness == Brightness.dark
            ? const [AppColors.darkSurfaceMuted, AppColors.darkSurface]
            : const [AppColors.lightSurface, AppColors.lightSurfaceMuted],
  );
}
