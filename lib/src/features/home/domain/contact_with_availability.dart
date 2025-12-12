import '../../availability/domain/availability_status.dart';

/// A contact with their availability info, aggregated across circles
/// Used for the Home screen availability grid
class ContactWithAvailability {
  static const _undefined = Object();

  final String userId;
  final String name;
  final String? avatarUrl;
  final AvailabilityStatus status;
  final String? statusMessage;
  final DateTime? lastSeen;
  final List<String> circleIds; // Which circles this contact is in
  final String? circleNickname; // Nickname from primary circle

  ContactWithAvailability({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.status = AvailabilityStatus.offline,
    this.statusMessage,
    this.lastSeen,
    List<String> circleIds = const [],
    this.circleNickname,
  }) : circleIds = List.unmodifiable(circleIds);

  ContactWithAvailability copyWith({
    String? userId,
    String? name,
    Object? avatarUrl = _undefined,
    AvailabilityStatus? status,
    Object? statusMessage = _undefined,
    Object? lastSeen = _undefined,
    List<String>? circleIds,
    Object? circleNickname = _undefined,
  }) {
    return ContactWithAvailability(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl == _undefined
          ? this.avatarUrl
          : avatarUrl as String?,
      status: status ?? this.status,
      statusMessage: statusMessage == _undefined
          ? this.statusMessage
          : statusMessage as String?,
      lastSeen: lastSeen == _undefined ? this.lastSeen : lastSeen as DateTime?,
      circleIds: circleIds ?? this.circleIds,
      circleNickname: circleNickname == _undefined
          ? this.circleNickname
          : circleNickname as String?,
    );
  }

  /// Returns the best available name (nickname > name), or null if none
  String? get resolvedName {
    final nickname = circleNickname?.trim();
    if (nickname != null && nickname.isNotEmpty) return nickname;
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) return trimmedName;
    return null;
  }

  bool get isOnline => status != AvailabilityStatus.offline;

  bool get isFreeToChat => status.isAvailableToChat;
}
