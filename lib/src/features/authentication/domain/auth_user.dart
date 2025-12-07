import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String email;
  final String? name;
  final String? pictureUrl;
  final bool emailVerified;

  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.pictureUrl,
    this.emailVerified = false,
  });

  factory AuthUser.fromAuth0(Map<String, dynamic> profile) {
    return AuthUser(
      id: profile['sub'] as String? ?? '',
      email: profile['email'] as String? ?? '',
      name: profile['name'] as String?,
      pictureUrl: profile['picture'] as String?,
      emailVerified: profile['email_verified'] as bool? ?? false,
    );
  }

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? pictureUrl,
    bool? emailVerified,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          pictureUrl == other.pictureUrl &&
          emailVerified == other.emailVerified;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      pictureUrl.hashCode ^
      emailVerified.hashCode;
}
