class ScheduledPost {
  const ScheduledPost({
    required this.id,
    required this.title,
    required this.platform,
    required this.scheduledAt,
    required this.status,
  });
  final String id;
  final String title;
  final String platform;
  final DateTime scheduledAt;
  final String status;
}
