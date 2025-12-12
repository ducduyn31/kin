/// Member role within a circle
enum MemberRole { admin, member }

extension MemberRoleX on MemberRole {
  String get label {
    switch (this) {
      case MemberRole.admin:
        return 'Admin';
      case MemberRole.member:
        return 'Member';
    }
  }

  String toApiValue() => name;

  static MemberRole fromApiValue(String value) {
    switch (value) {
      case 'admin':
        return MemberRole.admin;
      case 'member':
      default:
        return MemberRole.member;
    }
  }
}

/// A circle (group) of close contacts
class Circle {
  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final String createdBy;
  final MemberRole myRole;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Circle({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.createdBy,
    required this.myRole,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Circle copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? createdBy,
    MemberRole? myRole,
    int? memberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Circle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy,
      myRole: myRole ?? this.myRole,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAdmin => myRole == MemberRole.admin;
}
