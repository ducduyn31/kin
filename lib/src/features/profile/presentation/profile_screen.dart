import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/user_provider.dart';
import '../../contacts/domain/contact.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Open settings
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          // Profile Header
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor:
                              _getStatusColor(user.status),
                          child: Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Status Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Availability',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StatusOption(
                      status: AvailabilityStatus.available,
                      currentStatus: user.status,
                      onTap: () => ref
                          .read(userProvider.notifier)
                          .updateStatus(AvailabilityStatus.available),
                    ),
                    _StatusOption(
                      status: AvailabilityStatus.busy,
                      currentStatus: user.status,
                      onTap: () => ref
                          .read(userProvider.notifier)
                          .updateStatus(AvailabilityStatus.busy),
                    ),
                    _StatusOption(
                      status: AvailabilityStatus.away,
                      currentStatus: user.status,
                      onTap: () => ref
                          .read(userProvider.notifier)
                          .updateStatus(AvailabilityStatus.away),
                    ),
                    _StatusOption(
                      status: AvailabilityStatus.offline,
                      currentStatus: user.status,
                      onTap: () => ref
                          .read(userProvider.notifier)
                          .updateStatus(AvailabilityStatus.offline),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Menu Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _MenuTile(
                    icon: Icons.lock_outline,
                    title: 'Privacy',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _MenuTile(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _MenuTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: _MenuTile(
                icon: Icons.logout,
                title: 'Log Out',
                iconColor: theme.colorScheme.error,
                textColor: theme.colorScheme.error,
                onTap: () {
                  // TODO: Implement logout
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Color _getStatusColor(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return Colors.green;
      case AvailabilityStatus.busy:
        return Colors.red;
      case AvailabilityStatus.away:
        return Colors.orange;
      case AvailabilityStatus.offline:
        return Colors.grey;
    }
  }
}

class _StatusOption extends StatelessWidget {
  final AvailabilityStatus status;
  final AvailabilityStatus currentStatus;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.currentStatus,
    required this.onTap,
  });

  Color _getStatusColor(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return Colors.green;
      case AvailabilityStatus.busy:
        return Colors.red;
      case AvailabilityStatus.away:
        return Colors.orange;
      case AvailabilityStatus.offline:
        return Colors.grey;
    }
  }

  String _getStatusText(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return 'Available';
      case AvailabilityStatus.busy:
        return 'Busy';
      case AvailabilityStatus.away:
        return 'Away';
      case AvailabilityStatus.offline:
        return 'Appear Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = status == currentStatus;
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: _getStatusColor(status),
          shape: BoxShape.circle,
        ),
      ),
      title: Text(_getStatusText(status)),
      trailing: isSelected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
