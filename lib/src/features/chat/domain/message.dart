class Message {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isMe;
  final MessageStatus status;

  const Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isMe,
    this.status = MessageStatus.sent,
  });
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}
