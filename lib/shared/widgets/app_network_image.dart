import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/cache/social_flow_cache_manager.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_sizes.dart';
import 'app_skeleton.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.semanticLabel = 'Image distante',
    this.height = AppSizes.networkImageHeight,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String url;
  final String semanticLabel;
  final double height;
  final double width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: CachedNetworkImage(
          imageUrl: url,
          cacheManager: SocialFlowCacheManager.instance,
          width: width,
          height: height,
          fit: fit,
          placeholder: (_, _) => AppSkeleton(height: height, width: width),
          errorWidget:
              (_, _, _) => ColoredBox(
                color: scheme.surfaceContainerHighest,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: scheme.onSurfaceVariant,
                    size: AppSizes.iconHero,
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
