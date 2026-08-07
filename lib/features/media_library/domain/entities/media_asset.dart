enum MediaAssetType { image, video, audio, document }

class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.uri,
    this.thumbnailUrl,
  });

  final String id;
  final String name;
  final MediaAssetType type;
  final String uri;
  final String? thumbnailUrl;
}
