enum VideoSource { device, youtube, cloud }
enum VideoJobStatus { idle, preparing, transcribing, analyzing, clipping, completed, failed }

class VideoJob {
  const VideoJob({required this.source, required this.status, required this.progress, this.sourceUrl});
  final VideoSource source;
  final VideoJobStatus status;
  final int progress;
  final String? sourceUrl;

  VideoJob copyWith({VideoSource? source, VideoJobStatus? status, int? progress, String? sourceUrl}) => VideoJob(source: source ?? this.source, status: status ?? this.status, progress: progress ?? this.progress, sourceUrl: sourceUrl ?? this.sourceUrl);
}
