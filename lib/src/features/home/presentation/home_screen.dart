import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../application/home_provider.dart';
import '../domain/contact_with_availability.dart';
import '../../availability/domain/availability_status.dart';
import '../../availability/presentation/set_availability_sheet.dart';
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
            tooltip: l10n.yourStatusTooltip,
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
                  label: Text(l10n.filterAll),
                  selected: statusFilter == null,
                  onSelected: (_) {
                    ref.read(statusFilterProvider.notifier).clearFilter();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l10n.filterFreeCount(freeCount)),
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
                  label: Text(l10n.filterBusy),
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
                  label: Text(l10n.filterAway),
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
                              ? l10n.noContactsWithStatus(
                                  getStatusLabelLowercase(statusFilter, l10n),
                                )
                              : l10n.noContactsYet,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.joinCircleToSeeContacts,
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
                          _showQuickActions(context, contact, l10n);
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
    AppLocalizations l10n,
  ) {
    final displayName = contact.resolvedName ?? l10n.unknownContact;
    final trimmedDisplayName = displayName.trim();
    final initial = trimmedDisplayName.isNotEmpty
        ? trimmedDisplayName[0].toUpperCase()
        : '?';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(displayName),
              subtitle: Text(
                contact.statusMessage ?? getStatusLabel(contact.status, l10n),
                style: TextStyle(color: contact.status.color),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.message),
              title: Text(l10n.sendMessage),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to chat
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
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(l10n.viewProfile),
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
