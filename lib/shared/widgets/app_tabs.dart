import 'package:flutter/material.dart';

class AppTabs extends StatelessWidget {
  const AppTabs({
    required this.tabs,
    this.controller,
    this.onTap,
    this.isScrollable = true,
    super.key,
  });

  final List<String> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: isScrollable,
      tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
      onTap: onTap,
      tabs: tabs
          .map(
            (label) => Tab(
              height: 44,
              child: Text(label, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(growable: false),
    );
  }
}
