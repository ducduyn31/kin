import '../../../features/availability/domain/availability_status.dart';

/// Type of conversation
enum ConversationType {
  direct, // 1:1 DM
  circle, // Circle group chat
}

class Conversation {
  final String id;
  final ConversationType type;
  final String? circleId; // For circle conversations
  final String displayName; // Contact name or Circle name
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  // For direct conversations
  final String? contactId;
  final AvailabilityStatus? contactStatus;
  final String? contactStatusMessage;

  // For circle conversations
  final int? memberCount;

  const Conversation({
    required this.id,
    this.type = ConversationType.direct,
    this.circleId,
    required this.displayName,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.contactId,
    this.contactStatus,
    this.contactStatusMessage,
    this.memberCount,
  });

  /// Backwards compatibility
  String get contactName => displayName;
  String get contactAvatarUrl => avatarUrl ?? '';
  bool get isOnline =>
      contactStatus != null && contactStatus != AvailabilityStatus.offline;

  bool get isDirectMessage => type == ConversationType.direct;
  bool get isCircleChat => type == ConversationType.circle;
}
