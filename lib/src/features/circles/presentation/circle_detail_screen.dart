import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../application/circles_provider.dart';
import '../domain/circle.dart';
import '../domain/circle_member.dart';
import '../../authentication/application/auth_provider.dart';
import '../../availability/domain/availability_status.dart';
import '../../availability/presentation/set_availability_sheet.dart';
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
    final currentUserId = ref.watch(currentAuthUserProvider)?.id;

    final l10n = AppLocalizations.of(context)!;

    if (circle == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.circle)),
        body: Center(child: Text(l10n.circleNotFound)),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      var indexA = statusOrder.indexOf(a.status);
      var indexB = statusOrder.indexOf(b.status);

      if (indexA == -1) indexA = statusOrder.length;
      if (indexB == -1) indexB = statusOrder.length;
      return indexA.compareTo(indexB);
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
            tooltip: l10n.groupChat,
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
                  l10n.membersCount(circle.memberCount),
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
                    label: l10n.freeNow,
                    value: '$freeCount',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.people,
                    iconColor: colorScheme.primary,
                    label: l10n.members,
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
                  l10n.members,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (circle.isAdmin)
                  TextButton.icon(
                    onPressed: () {
                      _showInviteOptions(context, l10n);
                    },
                    icon: const Icon(Icons.person_add, size: 18),
                    label: Text(l10n.invite),
                  ),
              ],
            ),
          ),

          // Members list
          ...sortedMembers.map(
            (member) => MemberTile(
              member: member,
              onTap: () {
                _showMemberActions(
                  context,
                  member,
                  circle.isAdmin,
                  currentUserId,
                  l10n,
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Actions section
          const Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: colorScheme.error),
            title: Text(
              l10n.leaveCircle,
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () {
              _showLeaveConfirmation(context, circle, l10n);
            },
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _showInviteOptions(BuildContext context, AppLocalizations l10n) {
    final parentContext = context;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.inviteToCircle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(l10n.shareInviteLink),
              subtitle: Text(l10n.anyoneWithLinkCanJoin),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  parentContext,
                ).showSnackBar(SnackBar(content: Text(l10n.inviteLinkCopied)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: Text(l10n.showQrCode),
              subtitle: Text(l10n.scanToJoin),
              onTap: () {
                Navigator.pop(context);
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
    String? currentUserId,
    AppLocalizations l10n,
  ) {
    final displayName = member.resolvedName ?? l10n.unknownContact;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(initial),
              ),
              title: Text(displayName),
              subtitle: Text(
                member.statusMessage ?? getStatusLabel(member.status, l10n),
                style: TextStyle(color: member.status.color),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.message),
              title: Text(l10n.sendMessage),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to DM
              },
            ),
            ListTile(
              leading: const Icon(Icons.call),
              title: Text(l10n.call),
              onTap: () {
                Navigator.pop(context);
                // TODO: Initiate call
              },
            ),
            if (isAdmin &&
                currentUserId != null &&
                member.userId != currentUserId)
              ListTile(
                leading: Icon(
                  Icons.remove_circle_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  l10n.removeFromCircle,
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

  void _showLeaveConfirmation(
    BuildContext context,
    Circle circle,
    AppLocalizations l10n,
  ) {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveCircleQuestion),
        content: Text(
          circle.isAdmin
              ? l10n.leaveCircleAdminWarning
              : l10n.leaveCircleConfirmation(circle.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(content: Text(l10n.leftCircle(circle.name))),
              );
              Navigator.pop(parentContext);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.leave),
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
