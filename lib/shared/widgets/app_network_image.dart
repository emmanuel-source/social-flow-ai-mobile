import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/cache/social_flow_cache_manager.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({required this.url, this.height = 190, super.key});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: CachedNetworkImage(
        imageUrl: url,
        cacheManager: SocialFlowCacheManager.instance,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: height,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const CircularProgressIndicator(),
        ),
        errorWidget: (_, __, ___) => Container(
          height: height,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.image_not_supported_outlined),
        ),
      ),
    );
  }
}
