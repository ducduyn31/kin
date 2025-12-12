import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/circles_provider.dart';
import '../domain/circle.dart';
import '../domain/circle_member.dart';
import '../../availability/domain/availability_status.dart';
import 'widgets/circle_tile.dart';
import 'widgets/member_tile.dart';

class CircleDetailScreen extends ConsumerWidget {
  final String circleId;

  const CircleDetailScreen({super.key, required this.circleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circle = ref.watch(circleByIdProvider(circleId));
    final members = ref.watch(circleMembersProvider(circleId));
    final freeCount = ref.watch(circleFreeCountProvider(circleId));

    if (circle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Circle')),
        body: const Center(child: Text('Circle not found')),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Sort members: online first, then by status
    final sortedMembers = List.of(members);
    sortedMembers.sort((a, b) {
      final statusOrder = [
        AvailabilityStatus.free,
        AvailabilityStatus.away,
        AvailabilityStatus.busy,
        AvailabilityStatus.doNotDisturb,
        AvailabilityStatus.sleeping,
        AvailabilityStatus.offline,
      ];
      return statusOrder
          .indexOf(a.status)
          .compareTo(statusOrder.indexOf(b.status));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(circle.name),
        actions: [
          if (circle.isAdmin)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Navigate to circle settings
              },
            ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // TODO: Navigate to circle group chat
            },
            tooltip: 'Group chat',
          ),
        ],
      ),
      body: ListView(
        children: [
          // Circle header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatarWidget(
                  name: circle.name,
                  avatarUrl: circle.avatarUrl,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  circle.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (circle.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    circle.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${circle.memberCount} members',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Quick stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.circle,
                    iconColor: AvailabilityStatus.free.color,
                    label: 'Free now',
                    value: '$freeCount',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.people,
                    iconColor: colorScheme.primary,
                    label: 'Members',
                    value: '${circle.memberCount}',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Members section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Members',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (circle.isAdmin)
                  TextButton.icon(
                    onPressed: () {
                      _showInviteOptions(context);
                    },
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Invite'),
                  ),
              ],
            ),
          ),

          // Members list
          ...sortedMembers.map(
            (member) => MemberTile(
              member: member,
              onTap: () {
                _showMemberActions(context, member, circle.isAdmin);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Actions section
          const Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: colorScheme.error),
            title: Text(
              'Leave Circle',
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () {
              _showLeaveConfirmation(context, circle);
            },
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _showInviteOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Invite to Circle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Share invite link'),
              subtitle: const Text('Anyone with the link can join'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Generate and share invite link
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invite link copied! (mock)')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Show QR code'),
              subtitle: const Text('Scan to join'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show QR code
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showMemberActions(
    BuildContext context,
    CircleMember member,
    bool isAdmin,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(member.displayName[0].toUpperCase()),
              ),
              title: Text(member.displayName),
              subtitle: Text(
                member.statusMessage ?? member.status.label,
                style: TextStyle(color: member.status.color),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send message'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to DM
              },
            ),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Call'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Initiate call
              },
            ),
            if (isAdmin && member.userId != 'current-user')
              ListTile(
                leading: Icon(
                  Icons.remove_circle_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Remove from circle',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Remove member
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context, Circle circle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Circle?'),
        content: Text(
          circle.isAdmin
              ? 'You are an admin. If you leave, you must transfer admin rights first or the circle will be deleted if you are the only admin.'
              : 'Are you sure you want to leave "${circle.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // TODO: Leave circle
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Left "${circle.name}" (mock)')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
