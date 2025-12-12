import 'circle.dart';
import '../../availability/domain/availability_status.dart';

/// A member of a circle with their availability info
class CircleMember {
  final String id;
  final String circleId;
  final String userId;
  final MemberRole role;
  final String? nickname; // Circle-specific nickname
  final DateTime joinedAt;
  final DateTime updatedAt;

  // Denormalized user info for display
  final String name;
  final String? avatarUrl;
  final AvailabilityStatus status;
  final String? statusMessage;
  final DateTime? lastSeen;

  const CircleMember({
    required this.id,
    required this.circleId,
    required this.userId,
    required this.role,
    this.nickname,
    required this.joinedAt,
    required this.updatedAt,
    required this.name,
    this.avatarUrl,
    this.status = AvailabilityStatus.offline,
    this.statusMessage,
    this.lastSeen,
  });

  CircleMember copyWith({
    String? id,
    String? circleId,
    String? userId,
    MemberRole? role,
    String? nickname,
    DateTime? joinedAt,
    DateTime? updatedAt,
    String? name,
    String? avatarUrl,
    AvailabilityStatus? status,
    String? statusMessage,
    DateTime? lastSeen,
  }) {
    return CircleMember(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      nickname: nickname ?? this.nickname,
      joinedAt: joinedAt ?? this.joinedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  /// Display name (nickname if set, otherwise name)
  String get displayName => nickname ?? name;

  bool get isAdmin => role == MemberRole.admin;

  bool get isOnline => status != AvailabilityStatus.offline;
}
