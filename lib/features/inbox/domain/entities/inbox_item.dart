class InboxItem {
  const InboxItem({required this.platform, required this.author, required this.message, required this.receivedAt, this.read = false});
  final String platform;
  final String author;
  final String message;
  final DateTime receivedAt;
  final bool read;
}
