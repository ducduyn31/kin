import '../../availability/domain/availability_status.dart';

/// A contact with their availability info, aggregated across circles
/// Used for the Home screen availability grid
class ContactWithAvailability {
  final String userId;
  final String name;
  final String? avatarUrl;
  final AvailabilityStatus status;
  final String? statusMessage;
  final DateTime? lastSeen;
  final List<String> circleIds; // Which circles this contact is in
  final String? circleNickname; // Nickname from primary circle

  const ContactWithAvailability({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.status = AvailabilityStatus.offline,
    this.statusMessage,
    this.lastSeen,
    this.circleIds = const [],
    this.circleNickname,
  });

  ContactWithAvailability copyWith({
    String? userId,
    String? name,
    String? avatarUrl,
    AvailabilityStatus? status,
    String? statusMessage,
    DateTime? lastSeen,
    List<String>? circleIds,
    String? circleNickname,
  }) {
    return ContactWithAvailability(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      lastSeen: lastSeen ?? this.lastSeen,
      circleIds: circleIds ?? this.circleIds,
      circleNickname: circleNickname ?? this.circleNickname,
    );
  }

  /// Display name (nickname if set, otherwise name)
  String get displayName => circleNickname ?? name;

  bool get isOnline => status != AvailabilityStatus.offline;

  bool get isFreeToChat => status.isAvailableToChat;

  /// Format last seen time for display
  String? get lastSeenFormatted {
    if (lastSeen == null) return null;

    final now = DateTime.now();
    final diff = now.difference(lastSeen!);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return 'Long time ago';
    }
  }
}
