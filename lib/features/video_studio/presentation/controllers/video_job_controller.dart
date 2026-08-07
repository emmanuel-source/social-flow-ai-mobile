import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/video_job.dart';

final videoJobControllerProvider = NotifierProvider<VideoJobController, VideoJob>(VideoJobController.new);

class VideoJobController extends Notifier<VideoJob> {
  @override
  VideoJob build() => const VideoJob(source: VideoSource.youtube, status: VideoJobStatus.idle, progress: 0);

  void setSource(VideoSource source) => state = state.copyWith(source: source);
  void setUrl(String url) => state = state.copyWith(sourceUrl: url);

  Future<void> startAnalysis() async {
    state = state.copyWith(status: VideoJobStatus.preparing, progress: 5);
    for (var progress = 10; progress <= 100; progress += 5) {
      await Future<void>.delayed(const Duration(milliseconds: 110));
      final status = progress < 30
          ? VideoJobStatus.transcribing
          : progress < 70
              ? VideoJobStatus.analyzing
              : progress < 100
                  ? VideoJobStatus.clipping
                  : VideoJobStatus.completed;
      state = state.copyWith(status: status, progress: progress);
    }
  }
}
