class InvitationPreview {
  final String circleId;
  final String circleName;
  final String? circleDescription;
  final String? circleAvatarUrl;
  final int memberCount;
  final String inviterId;
  final String inviterName;
  final String? inviterAvatarUrl;

  const InvitationPreview({
    required this.circleId,
    required this.circleName,
    this.circleDescription,
    this.circleAvatarUrl,
    required this.memberCount,
    required this.inviterId,
    required this.inviterName,
    this.inviterAvatarUrl,
  });

  InvitationPreview copyWith({
    String? circleId,
    String? circleName,
    String? circleDescription,
    String? circleAvatarUrl,
    int? memberCount,
    String? inviterId,
    String? inviterName,
    String? inviterAvatarUrl,
  }) {
    return InvitationPreview(
      circleId: circleId ?? this.circleId,
      circleName: circleName ?? this.circleName,
      circleDescription: circleDescription ?? this.circleDescription,
      circleAvatarUrl: circleAvatarUrl ?? this.circleAvatarUrl,
      memberCount: memberCount ?? this.memberCount,
      inviterId: inviterId ?? this.inviterId,
      inviterName: inviterName ?? this.inviterName,
      inviterAvatarUrl: inviterAvatarUrl ?? this.inviterAvatarUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvitationPreview &&
        other.circleId == circleId &&
        other.circleName == circleName &&
        other.circleDescription == circleDescription &&
        other.circleAvatarUrl == circleAvatarUrl &&
        other.memberCount == memberCount &&
        other.inviterId == inviterId &&
        other.inviterName == inviterName &&
        other.inviterAvatarUrl == inviterAvatarUrl;
  }

  @override
  int get hashCode => Object.hash(
    circleId,
    circleName,
    circleDescription,
    circleAvatarUrl,
    memberCount,
    inviterId,
    inviterName,
    inviterAvatarUrl,
  );

  @override
  String toString() {
    return 'InvitationPreview('
        'circleId: $circleId, '
        'circleName: $circleName, '
        'memberCount: $memberCount, '
        'inviterName: $inviterName)';
  }
}
