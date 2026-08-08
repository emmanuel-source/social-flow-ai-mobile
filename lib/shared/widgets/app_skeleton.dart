import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';

class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    required this.height,
    this.width = double.infinity,
    this.borderRadius = AppRadius.md,
    super.key,
  });

  final double height;
  final double width;
  final double borderRadius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton> {
  var _highlighted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _highlighted = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Contenu en chargement',
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : AppMotion.emphasized,
        onEnd: () {
          if (!reduceMotion && mounted) {
            setState(() => _highlighted = !_highlighted);
          }
        },
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color:
              _highlighted
                  ? scheme.surfaceContainerHighest
                  : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
