import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const none = 0.0;
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 40.0;
  static const giant = 48.0;

  static const screenHorizontal = lg;
  static const screenTop = md;
  static const screenBottom = xxxl;
  static const cardPadding = md;
  static const controlGap = sm;
  static const sectionGap = lg;

  static const screenInsets = EdgeInsets.fromLTRB(
    screenHorizontal,
    screenTop,
    screenHorizontal,
    screenBottom,
  );
}
