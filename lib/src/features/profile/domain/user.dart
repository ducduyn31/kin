import '../../contacts/domain/contact.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final AvailabilityStatus status;
  final String? statusMessage;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.status,
    this.statusMessage,
  });

  User copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    AvailabilityStatus? status,
    String? statusMessage,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
