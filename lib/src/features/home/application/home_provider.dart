import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/contact_with_availability.dart';
import '../../circles/application/circles_provider.dart';
import '../../circles/domain/circle_member.dart';
import '../../availability/domain/availability_status.dart';
import '../../authentication/application/auth_provider.dart';

const _statusPriority = [
  AvailabilityStatus.free,
  AvailabilityStatus.away,
  AvailabilityStatus.busy,
  AvailabilityStatus.doNotDisturb,
  AvailabilityStatus.sleeping,
  AvailabilityStatus.offline,
];

AvailabilityStatus _pickBestStatus(AvailabilityStatus a, AvailabilityStatus b) {
  final priorityA = _statusPriority.indexOf(a);
  final priorityB = _statusPriority.indexOf(b);
  return priorityA <= priorityB ? a : b;
}

T _pickLatest<T>(
  T current,
  T candidate,
  DateTime? currentLastSeen,
  DateTime? candidateLastSeen,
) {
  if (candidateLastSeen == null) return current;
  if (currentLastSeen == null) return candidate;
  return candidateLastSeen.isAfter(currentLastSeen) ? candidate : current;
}

T? _pickLatestNonNull<T>(
  T? current,
  T? candidate,
  DateTime? currentLastSeen,
  DateTime? candidateLastSeen,
) {
  // If candidate is null, keep current regardless of timestamps
  if (candidate == null) return current;
  // If current is null, use candidate
  if (current == null) return candidate;
  // Both non-null: pick based on most recent lastSeen
  if (candidateLastSeen == null) return current;
  if (currentLastSeen == null) return candidate;
  return candidateLastSeen.isAfter(currentLastSeen) ? candidate : current;
}

class HomeNotifier extends Notifier<List<ContactWithAvailability>> {
  @override
  List<ContactWithAvailability> build() {
    final circles = ref.watch(circlesProvider);
    final allMembersByCircle = ref.watch(circleMembersNotifierProvider);
    final currentUserId = ref.watch(currentAuthUserProvider)?.id;

    final contactsMap = <String, _ContactAccumulator>{};

    for (final circle in circles) {
      final members = allMembersByCircle[circle.id] ?? <CircleMember>[];

      for (final member in members) {
        if (currentUserId != null && member.userId == currentUserId) continue;

        if (contactsMap.containsKey(member.userId)) {
          final existing = contactsMap[member.userId]!;
          existing.circleIds.add(circle.id);

          final bestStatus = _pickBestStatus(existing.status, member.status);
          final bestStatusMessage = _pickLatestNonNull(
            existing.statusMessage,
            member.statusMessage,
            existing.lastSeen,
            member.lastSeen,
          );
          final bestLastSeen = _pickLatest(
            existing.lastSeen,
            member.lastSeen,
            existing.lastSeen,
            member.lastSeen,
          );

          existing.status = bestStatus;
          existing.statusMessage = bestStatusMessage;
          existing.lastSeen = bestLastSeen;
          existing.circleNickname ??= member.nickname;
        } else {
          contactsMap[member.userId] = _ContactAccumulator(
            userId: member.userId,
            name: member.name,
            avatarUrl: member.avatarUrl,
            status: member.status,
            statusMessage: member.statusMessage,
            lastSeen: member.lastSeen,
            circleIds: {circle.id},
            circleNickname: member.nickname,
          );
        }
      }
    }

    return contactsMap.values
        .map(
          (acc) => ContactWithAvailability(
            userId: acc.userId,
            name: acc.name,
            avatarUrl: acc.avatarUrl,
            status: acc.status,
            statusMessage: acc.statusMessage,
            lastSeen: acc.lastSeen,
            circleIds: acc.circleIds.toList(),
            circleNickname: acc.circleNickname,
          ),
        )
        .toList();
  }
}

class _ContactAccumulator {
  final String userId;
  final String name;
  final String? avatarUrl;
  AvailabilityStatus status;
  String? statusMessage;
  DateTime? lastSeen;
  final Set<String> circleIds;
  String? circleNickname;

  _ContactAccumulator({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.status,
    this.statusMessage,
    this.lastSeen,
    required this.circleIds,
    this.circleNickname,
  });
}

final allContactsProvider =
    NotifierProvider<HomeNotifier, List<ContactWithAvailability>>(
      HomeNotifier.new,
    );

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

final contactsGroupedByStatusProvider =
    Provider<Map<AvailabilityStatus, List<ContactWithAvailability>>>((ref) {
      final contacts = ref.watch(allContactsProvider);

      final grouped = <AvailabilityStatus, List<ContactWithAvailability>>{};
      for (final status in AvailabilityStatus.values) {
        grouped[status] = contacts.where((c) => c.status == status).toList();
      }

      return grouped;
    });

final freeContactsCountProvider = Provider<int>((ref) {
  final contacts = ref.watch(allContactsProvider);
  return contacts.where((c) => c.status == AvailabilityStatus.free).length;
});

enum HomeViewMode {
  byAvailability, // Flat grid sorted by availability
  byCircle, // Grouped by circle
}

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

final filteredContactsProvider = Provider<List<ContactWithAvailability>>((ref) {
  final contacts = ref.watch(contactsSortedByAvailabilityProvider);
  final filter = ref.watch(statusFilterProvider);

  if (filter == null) {
    return contacts;
  }

  return contacts.where((c) => c.status == filter).toList();
});
