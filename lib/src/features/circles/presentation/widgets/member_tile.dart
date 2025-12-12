import 'package:flutter/material.dart';
import '../../domain/circle_member.dart';
import '../../../availability/domain/availability_status.dart';
import '../../../home/presentation/widgets/availability_card.dart';

/// List tile for displaying a circle member
class MemberTile extends StatelessWidget {
  final CircleMember member;
  final VoidCallback? onTap;

  const MemberTile({super.key, required this.member, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? Text(
                    member.displayName[0].toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : null,
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
          Flexible(
            child: Text(member.displayName, overflow: TextOverflow.ellipsis),
          ),
          if (member.isAdmin) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Admin',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
          if (member.userId == 'current-user') ...[
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
        member.statusMessage ?? member.status.label,
        style: TextStyle(color: member.status.color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: member.status.isAvailableToChat
          ? Icon(Icons.circle, size: 8, color: member.status.color)
          : null,
      onTap: member.userId != 'current-user' ? onTap : null,
    );
  }
}
