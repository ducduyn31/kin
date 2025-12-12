import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/contact_with_availability.dart';
import '../../circles/application/circles_provider.dart';
import '../../availability/domain/availability_status.dart';

/// Provider that aggregates all contacts from all circles into a single list
/// with their availability status for the home screen grid
final allContactsProvider = Provider<List<ContactWithAvailability>>((ref) {
  final circles = ref.watch(circlesProvider);

  // Collect all members from all circles, excluding current user
  final contactsMap = <String, ContactWithAvailability>{};

  for (final circle in circles) {
    final members = ref.watch(circleMembersProvider(circle.id));

    for (final member in members) {
      // Skip current user
      if (member.userId == 'current-user') continue;

      if (contactsMap.containsKey(member.userId)) {
        // Update existing contact with additional circle
        final existing = contactsMap[member.userId]!;
        contactsMap[member.userId] = existing.copyWith(
          circleIds: [...existing.circleIds, circle.id],
          // Keep the first nickname found
          circleNickname: existing.circleNickname ?? member.nickname,
          // Update status if newer
          status: member.status,
          statusMessage: member.statusMessage,
          lastSeen: member.lastSeen,
        );
      } else {
        // Add new contact
        contactsMap[member.userId] = ContactWithAvailability(
          userId: member.userId,
          name: member.name,
          avatarUrl: member.avatarUrl,
          status: member.status,
          statusMessage: member.statusMessage,
          lastSeen: member.lastSeen,
          circleIds: [circle.id],
          circleNickname: member.nickname,
        );
      }
    }
  }

  return contactsMap.values.toList();
});

/// Provider for contacts sorted by availability (free contacts first)
final contactsSortedByAvailabilityProvider =
    Provider<List<ContactWithAvailability>>((ref) {
      final contacts = ref.watch(allContactsProvider);

      // Sort: Free > Away > Busy > DND > Sleeping > Offline
      final sorted = List<ContactWithAvailability>.from(contacts);
      sorted.sort((a, b) {
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

      return sorted;
    });

/// Provider for contacts grouped by status
final contactsGroupedByStatusProvider =
    Provider<Map<AvailabilityStatus, List<ContactWithAvailability>>>((ref) {
      final contacts = ref.watch(allContactsProvider);

      final grouped = <AvailabilityStatus, List<ContactWithAvailability>>{};
      for (final status in AvailabilityStatus.values) {
        grouped[status] = contacts.where((c) => c.status == status).toList();
      }

      return grouped;
    });

/// Provider for count of free contacts
final freeContactsCountProvider = Provider<int>((ref) {
  final contacts = ref.watch(allContactsProvider);
  return contacts.where((c) => c.status == AvailabilityStatus.free).length;
});

/// Enum for home screen view mode
enum HomeViewMode {
  byAvailability, // Flat grid sorted by availability
  byCircle, // Grouped by circle
}

/// Provider for current home view mode
final homeViewModeProvider =
    NotifierProvider<HomeViewModeNotifier, HomeViewMode>(
      HomeViewModeNotifier.new,
    );

class HomeViewModeNotifier extends Notifier<HomeViewMode> {
  @override
  HomeViewMode build() => HomeViewMode.byAvailability;

  void setMode(HomeViewMode mode) {
    state = mode;
  }

  void toggle() {
    state = state == HomeViewMode.byAvailability
        ? HomeViewMode.byCircle
        : HomeViewMode.byAvailability;
  }
}

/// Provider for status filter
final statusFilterProvider =
    NotifierProvider<StatusFilterNotifier, AvailabilityStatus?>(
      StatusFilterNotifier.new,
    );

class StatusFilterNotifier extends Notifier<AvailabilityStatus?> {
  @override
  AvailabilityStatus? build() => null; // null means show all

  void setFilter(AvailabilityStatus? status) {
    state = status;
  }

  void clearFilter() {
    state = null;
  }
}

/// Provider for filtered contacts based on status filter
final filteredContactsProvider = Provider<List<ContactWithAvailability>>((ref) {
  final contacts = ref.watch(contactsSortedByAvailabilityProvider);
  final filter = ref.watch(statusFilterProvider);

  if (filter == null) {
    return contacts;
  }

  return contacts.where((c) => c.status == filter).toList();
});
