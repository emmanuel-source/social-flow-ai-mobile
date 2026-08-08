import 'package:flutter/material.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';

Widget buildTestApp(
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
  Size size = const Size(320, 640),
}) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    home: Center(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: MediaQuery(
          data: MediaQueryData(size: size),
          child: Scaffold(body: SafeArea(child: child)),
        ),
      ),
    ),
  );
}
