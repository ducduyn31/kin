import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/circle_member.dart';
import '../../../authentication/application/auth_provider.dart';
import '../../../availability/domain/availability_status.dart';
import '../../../availability/presentation/set_availability_sheet.dart';
import '../../../home/presentation/widgets/availability_card.dart';

class MemberTile extends ConsumerWidget {
  final CircleMember member;
  final VoidCallback? onTap;

  const MemberTile({super.key, required this.member, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = ref.watch(currentAuthUserProvider)?.id;
    final isCurrentUser = member.userId == currentUserId;

    final trimmedAvatarUrl = member.avatarUrl?.trim();
    final hasValidAvatar =
        trimmedAvatarUrl != null && trimmedAvatarUrl.isNotEmpty;
    final displayName = member.resolvedName ?? l10n.unknownContact;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: hasValidAvatar
                ? NetworkImage(trimmedAvatarUrl)
                : null,
            child: hasValidAvatar
                ? null
                : Text(
                    initial,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: AvailabilityStatusBadge(status: member.status, size: 14),
          ),
        ],
      ),
      title: Row(
        children: [
          Flexible(child: Text(displayName, overflow: TextOverflow.ellipsis)),
          if (member.isAdmin) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                l10n.admin,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            Text(
              '(You)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        member.statusMessage ?? getStatusLabel(member.status, l10n),
        style: TextStyle(color: member.status.color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: member.status.isAvailableToChat
          ? Icon(Icons.circle, size: 8, color: member.status.color)
          : null,
      onTap: isCurrentUser ? null : onTap,
    );
  }
}
