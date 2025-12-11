import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/src/l10n/app_localizations.dart';
import '../application/user_provider.dart';
import '../../authentication/application/auth_provider.dart';
import '../../contacts/domain/contact.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
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
                          backgroundColor: user.status.color,
                          child: const Icon(
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
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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
                      l10n.availability,
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
                    title: l10n.notifications,
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _MenuTile(
                    icon: Icons.lock_outline,
                    title: l10n.privacy,
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _MenuTile(
                    icon: Icons.palette_outlined,
                    title: l10n.appearance,
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _MenuTile(
                    icon: Icons.help_outline,
                    title: l10n.helpAndSupport,
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
                title: l10n.logOut,
                iconColor: theme.colorScheme.error,
                textColor: theme.colorScheme.error,
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logOut),
        content: Text(l10n.logOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
            },
            child: Text(l10n.logOut),
          ),
        ],
      ),
    );
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

  String _getStatusText(BuildContext context, AvailabilityStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case AvailabilityStatus.available:
        return l10n.statusAvailable;
      case AvailabilityStatus.busy:
        return l10n.statusBusy;
      case AvailabilityStatus.away:
        return l10n.statusAway;
      case AvailabilityStatus.offline:
        return l10n.appearOffline;
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
        decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
      ),
      title: Text(_getStatusText(context, status)),
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
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
