import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../application/home_provider.dart';
import '../domain/contact_with_availability.dart';
import '../../availability/domain/availability_status.dart';
import 'widgets/availability_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final contacts = ref.watch(filteredContactsProvider);
    final freeCount = ref.watch(freeContactsCountProvider);
    final statusFilter = ref.watch(statusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              // TODO: Open your status settings
            },
            tooltip: 'Your status',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: statusFilter == null,
                  onSelected: (_) {
                    ref.read(statusFilterProvider.notifier).clearFilter();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text('Free ($freeCount)'),
                  selected: statusFilter == AvailabilityStatus.free,
                  onSelected: (_) {
                    ref
                        .read(statusFilterProvider.notifier)
                        .setFilter(
                          statusFilter == AvailabilityStatus.free
                              ? null
                              : AvailabilityStatus.free,
                        );
                  },
                  avatar: Icon(
                    AvailabilityStatus.free.icon,
                    color: AvailabilityStatus.free.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Busy'),
                  selected: statusFilter == AvailabilityStatus.busy,
                  onSelected: (_) {
                    ref
                        .read(statusFilterProvider.notifier)
                        .setFilter(
                          statusFilter == AvailabilityStatus.busy
                              ? null
                              : AvailabilityStatus.busy,
                        );
                  },
                  avatar: Icon(
                    AvailabilityStatus.busy.icon,
                    color: AvailabilityStatus.busy.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Away'),
                  selected: statusFilter == AvailabilityStatus.away,
                  onSelected: (_) {
                    ref
                        .read(statusFilterProvider.notifier)
                        .setFilter(
                          statusFilter == AvailabilityStatus.away
                              ? null
                              : AvailabilityStatus.away,
                        );
                  },
                  avatar: Icon(
                    AvailabilityStatus.away.icon,
                    color: AvailabilityStatus.away.color,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          // Contacts grid
          Expanded(
            child: contacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          statusFilter != null
                              ? 'No contacts ${statusFilter.label.toLowerCase()}'
                              : 'No contacts yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join a circle to see your contacts',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return AvailabilityCard(
                        contact: contact,
                        onTap: () {
                          _showQuickActions(context, contact);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(
    BuildContext context,
    ContactWithAvailability contact,
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
                child: Text(
                  contact.displayName[0].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(contact.displayName),
              subtitle: Text(
                contact.statusMessage ?? contact.status.label,
                style: TextStyle(color: contact.status.color),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send message'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to chat
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
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View profile'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to contact profile
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
