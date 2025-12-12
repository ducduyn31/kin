import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../availability/domain/availability_status.dart';
import '../../domain/circle.dart';

class CircleTile extends StatelessWidget {
  final Circle circle;
  final int freeCount;
  final VoidCallback? onTap;

  const CircleTile({
    super.key,
    required this.circle,
    required this.freeCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: CircleAvatarWidget(
        name: circle.name,
        avatarUrl: circle.avatarUrl,
      ),
      title: Text(
        circle.name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              l10n.membersCount(circle.memberCount),
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (circle.isAdmin) ...[
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
        ],
      ),
      trailing: freeCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AvailabilityStatus.free.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: AvailabilityStatus.free.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.freeWithCount(freeCount),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AvailabilityStatus.free.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

/// Circle avatar widget
class CircleAvatarWidget extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;

  const CircleAvatarWidget({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData icon = Icons.groups;
    if (name.toLowerCase().contains('family')) {
      icon = Icons.family_restroom;
    } else if (name.toLowerCase().contains('friend')) {
      icon = Icons.diversity_3;
    } else if (name.toLowerCase().contains('work')) {
      icon = Icons.work;
    }

    final trimmedAvatarUrl = avatarUrl?.trim();
    final hasValidAvatar =
        trimmedAvatarUrl != null && trimmedAvatarUrl.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        image: hasValidAvatar
            ? DecorationImage(
                image: NetworkImage(trimmedAvatarUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasValidAvatar
          ? null
          : Icon(icon, color: colorScheme.onPrimaryContainer, size: size * 0.5),
    );
  }
}
