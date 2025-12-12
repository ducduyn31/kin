import 'package:flutter/material.dart';
import '../../domain/circle.dart';
import '../../../availability/domain/availability_status.dart';

/// List tile for displaying a circle
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
          Text(
            '${circle.memberCount} members',
            style: theme.textTheme.bodySmall,
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
                'Admin',
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
                    '$freeCount free',
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

    // Get icon based on circle name
    IconData icon = Icons.groups;
    if (name.toLowerCase().contains('family')) {
      icon = Icons.family_restroom;
    } else if (name.toLowerCase().contains('friend')) {
      icon = Icons.diversity_3;
    } else if (name.toLowerCase().contains('work')) {
      icon = Icons.work;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        image: avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatarUrl == null
          ? Icon(icon, color: colorScheme.onPrimaryContainer, size: size * 0.5)
          : null,
    );
  }
}
