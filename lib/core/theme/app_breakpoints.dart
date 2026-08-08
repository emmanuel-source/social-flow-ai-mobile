abstract final class AppBreakpoints {
  static const compact = 360.0;
  static const medium = 600.0;
  static const expanded = 840.0;

  static bool isCompact(double width) => width < compact;
  static bool isMedium(double width) => width >= medium && width < expanded;
  static bool isExpanded(double width) => width >= expanded;
}
