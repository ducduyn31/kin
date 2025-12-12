/// Type of circle invitation
enum InvitationType {
  direct, // Invite specific user
  link, // Shareable link
}

extension InvitationTypeX on InvitationType {
  String toApiValue() => name;

  static InvitationType fromApiValue(String value) {
    switch (value) {
      case 'direct':
        return InvitationType.direct;
      case 'link':
      default:
        return InvitationType.link;
    }
  }
}

/// Status of an invitation
enum InvitationStatus { pending, accepted, expired, revoked }

extension InvitationStatusX on InvitationStatus {
  String toApiValue() => name;

  static InvitationStatus fromApiValue(String value) {
    switch (value) {
      case 'pending':
        return InvitationStatus.pending;
      case 'accepted':
        return InvitationStatus.accepted;
      case 'expired':
        return InvitationStatus.expired;
      case 'revoked':
        return InvitationStatus.revoked;
      default:
        return InvitationStatus.pending;
    }
  }
}

/// An invitation to join a circle
class CircleInvitation {
  final String id;
  final String circleId;
  final String inviterId;
  final String? inviteeId; // Only for direct invitations
  final InvitationType type;
  final String code;
  final InvitationStatus status;
  final int? maxUses;
  final int useCount;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CircleInvitation({
    required this.id,
    required this.circleId,
    required this.inviterId,
    this.inviteeId,
    required this.type,
    required this.code,
    required this.status,
    this.maxUses,
    this.useCount = 0,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  CircleInvitation copyWith({
    String? id,
    String? circleId,
    String? inviterId,
    String? inviteeId,
    InvitationType? type,
    String? code,
    InvitationStatus? status,
    int? maxUses,
    int? useCount,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CircleInvitation(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      inviterId: inviterId ?? this.inviterId,
      inviteeId: inviteeId ?? this.inviteeId,
      type: type ?? this.type,
      code: code ?? this.code,
      status: status ?? this.status,
      maxUses: maxUses ?? this.maxUses,
      useCount: useCount ?? this.useCount,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isUsable {
    if (status != InvitationStatus.pending) return false;
    if (isExpired) return false;
    if (maxUses != null && useCount >= maxUses!) return false;
    return true;
  }

  /// Get the shareable link for this invitation
  String get shareLink => 'kin://join/$code';
}
