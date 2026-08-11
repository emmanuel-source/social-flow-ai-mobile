import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  static const xs = 6.0;
  static const sm = 8.0;
  static const md = 10.0;
  static const lg = 14.0;
  static const xl = 18.0;
  static const pill = 999.0;

  static const card = BorderRadius.all(Radius.circular(lg));
  static const control = BorderRadius.all(Radius.circular(md));
  static const modal = BorderRadius.all(Radius.circular(xl));
  static const capsule = BorderRadius.all(Radius.circular(pill));
}
