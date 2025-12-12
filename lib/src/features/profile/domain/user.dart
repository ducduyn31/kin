import '../../availability/domain/availability_status.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final AvailabilityStatus status;
  final String? statusMessage;
  final DateTime? statusExpiresAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.status,
    this.statusMessage,
    this.statusExpiresAt,
  });

  User copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    AvailabilityStatus? status,
    Object? statusMessage = _sentinel,
    Object? statusExpiresAt = _sentinel,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      statusMessage: statusMessage == _sentinel
          ? this.statusMessage
          : statusMessage as String?,
      statusExpiresAt: statusExpiresAt == _sentinel
          ? this.statusExpiresAt
          : statusExpiresAt as DateTime?,
    );
  }
}

const _sentinel = Object();
