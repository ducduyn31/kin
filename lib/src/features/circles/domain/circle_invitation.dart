import 'package:flutter/foundation.dart';

class _Undefined {
  const _Undefined();
}

const _undefined = _Undefined();

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
        return InvitationType.link;
      default:
        debugPrint(
          '[InvitationTypeX] Unknown InvitationType value: $value, defaulting to link',
        );
        return InvitationType.link;
    }
  }
}

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
        debugPrint(
          '[InvitationStatusX] Unknown InvitationStatus value: $value, defaulting to pending',
        );
        return InvitationStatus.pending;
    }
  }
}

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
  }) : assert(
         type != InvitationType.direct || inviteeId != null,
         'Direct invitations must have an inviteeId',
       ),
       assert(
         type != InvitationType.direct || (maxUses != null && maxUses == 1),
         'Direct invitations must be single-use (maxUses == 1)',
       ),
       assert(
         type != InvitationType.link || inviteeId == null,
         'Link invitations must not have an inviteeId',
       ),
       assert(useCount >= 0, 'useCount cannot be negative'),
       assert(maxUses == null || maxUses >= 0, 'maxUses cannot be negative'),
       assert(
         maxUses == null || useCount <= maxUses,
         'useCount cannot exceed maxUses',
       );

  CircleInvitation copyWith({
    String? id,
    String? circleId,
    String? inviterId,
    Object? inviteeId = _undefined,
    InvitationType? type,
    String? code,
    InvitationStatus? status,
    Object? maxUses = _undefined,
    int? useCount,
    Object? expiresAt = _undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CircleInvitation(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      inviterId: inviterId ?? this.inviterId,
      inviteeId: inviteeId == _undefined
          ? this.inviteeId
          : inviteeId as String?,
      type: type ?? this.type,
      code: code ?? this.code,
      status: status ?? this.status,
      maxUses: maxUses == _undefined ? this.maxUses : maxUses as int?,
      useCount: useCount ?? this.useCount,
      expiresAt: expiresAt == _undefined
          ? this.expiresAt
          : expiresAt as DateTime?,
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
    final effectiveMaxUses = type == InvitationType.direct ? 1 : maxUses;
    if (effectiveMaxUses != null && useCount >= effectiveMaxUses) return false;
    return true;
  }

  Uri get shareLink => Uri(scheme: 'kin', host: 'join', pathSegments: [code]);
}
