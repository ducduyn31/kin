class Conversation {
  final String id;
  final String contactName;
  final String contactAvatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const Conversation({
    required this.id,
    required this.contactName,
    required this.contactAvatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}
