import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/circle.dart';
import '../domain/circle_member.dart';
import '../../availability/domain/availability_status.dart';

class CirclesNotifier extends Notifier<List<Circle>> {
  @override
  List<Circle> build() => _mockCircles;

  Circle? getById(String circleId) {
    try {
      return state.firstWhere((c) => c.id == circleId);
    } catch (_) {
      return null;
    }
  }
}

final circlesProvider = NotifierProvider<CirclesNotifier, List<Circle>>(
  CirclesNotifier.new,
);

final circleByIdProvider = Provider.family<Circle?, String>((ref, circleId) {
  final circles = ref.watch(circlesProvider);
  try {
    return circles.firstWhere((c) => c.id == circleId);
  } catch (_) {
    return null;
  }
});

class CircleMembersNotifier extends Notifier<Map<String, List<CircleMember>>> {
  @override
  Map<String, List<CircleMember>> build() => _mockMembersByCircle;

  List<CircleMember> getMembersForCircle(String circleId) {
    return state[circleId] ?? [];
  }

  int getFreeCount(String circleId) {
    final members = getMembersForCircle(circleId);
    return members.where((m) => m.status == AvailabilityStatus.free).length;
  }
}

final circleMembersNotifierProvider =
    NotifierProvider<CircleMembersNotifier, Map<String, List<CircleMember>>>(
      CircleMembersNotifier.new,
    );

final circleMembersProvider = Provider.family<List<CircleMember>, String>((
  ref,
  circleId,
) {
  final membersByCircle = ref.watch(circleMembersNotifierProvider);
  return membersByCircle[circleId] ?? [];
});

final circleFreeCountProvider = Provider.family<int, String>((ref, circleId) {
  final members = ref.watch(circleMembersProvider(circleId));
  return members.where((m) => m.status == AvailabilityStatus.free).length;
});

// Fixed reference date for deterministic mock data timestamps
final _mockBaseDate = DateTime.utc(2024, 1, 15, 12, 0, 0);

final _mockCircles = [
  Circle(
    id: 'circle-1',
    name: 'Family',
    description: 'Stay connected with the fam',
    avatarUrl: null,
    createdBy: 'current-user',
    myRole: MemberRole.admin,
    memberCount: 4,
    createdAt: _mockBaseDate.subtract(const Duration(days: 90)),
    updatedAt: _mockBaseDate,
  ),
  Circle(
    id: 'circle-2',
    name: 'Close Friends',
    description: 'The inner circle',
    avatarUrl: null,
    createdBy: 'user-alice',
    myRole: MemberRole.member,
    memberCount: 5,
    createdAt: _mockBaseDate.subtract(const Duration(days: 60)),
    updatedAt: _mockBaseDate,
  ),
  Circle(
    id: 'circle-3',
    name: 'Work Buddies',
    description: 'Colleagues who became friends',
    avatarUrl: null,
    createdBy: 'current-user',
    myRole: MemberRole.admin,
    memberCount: 3,
    createdAt: _mockBaseDate.subtract(const Duration(days: 30)),
    updatedAt: _mockBaseDate,
  ),
];

final _mockMembersByCircle = <String, List<CircleMember>>{
  'circle-1': [
    CircleMember(
      id: 'member-1',
      circleId: 'circle-1',
      userId: 'user-mom',
      role: MemberRole.member,
      nickname: null,
      joinedAt: _mockBaseDate.subtract(const Duration(days: 90)),
      updatedAt: _mockBaseDate,
      name: 'Mom',
      avatarUrl: null,
      status: AvailabilityStatus.free,
      statusMessage: 'At home',
    ),
    CircleMember(
      id: 'member-2',
      circleId: 'circle-1',
      userId: 'user-dad',
      role: MemberRole.member,
      nickname: null,
      joinedAt: _mockBaseDate.subtract(const Duration(days: 90)),
      updatedAt: _mockBaseDate,
      name: 'Dad',
      avatarUrl: null,
      status: AvailabilityStatus.away,
      statusMessage: 'Driving',
    ),
    CircleMember(
      id: 'member-3',
      circleId: 'circle-1',
      userId: 'user-sister',
      role: MemberRole.member,
      nickname: 'Sis',
      joinedAt: _mockBaseDate.subtract(const Duration(days: 85)),
      updatedAt: _mockBaseDate,
      name: 'Sarah',
      avatarUrl: null,
      status: AvailabilityStatus.busy,
      statusMessage: 'Work meeting',
    ),
    CircleMember(
      id: 'member-4',
      circleId: 'circle-1',
      userId: 'current-user',
      role: MemberRole.admin,
      nickname: null,
      joinedAt: _mockBaseDate.subtract(const Duration(days: 90)),
      updatedAt: _mockBaseDate,
      name: 'You',
      avatarUrl: null,
      status: AvailabilityStatus.free,
      statusMessage: 'Working from home',
    ),
  ],
  'circle-2': [
    CircleMember(
      id: 'member-5',
      circleId: 'circle-2',
      userId: 'user-alice',
      role: MemberRole.admin,
      nickname: null,
      joinedAt: _mockBaseDate.subtract(const Duration(days: 60)),
      updatedAt: _mockBaseDate,
      name: 'Alice',
      avatarUrl: null,
      status: AvailabilityStatus.free,
      statusMessage: 'Free to chat!',
    ),
    CircleMember(
      id: 'member-6',
      circleId: 'circle-2',
      userId: 'user-bob',
      role: MemberRole.member,
      nickname: null,
      joinedAt: _mockBaseDate.subtract(const Duration(days: 55)),
      updatedAt: _mockBaseDate,
      name: 'Bob',
      avatarUrl: null,
      status: AvailabilityStatus.busy,
      statusMessage: 'In a meeting',
    ),
    CircleMember(
      id: 'member-7',
      circleId: 'circle-2',
      userId: 'user-charlie',
      role: MemberRole.member,
      nickname: null,
      joinedAt: _mockBaseDate.subtract(const Duration(days: 50)),
      updatedAt: _mockBaseDate,
      name: 'Charlie',
      avatarUrl: null,
      status: AvailabilityStatus.sleeping,
      statusMessage: null,
    ),
    CircleMember(
      id: 'member-8',
      circleId: 'circle-2',
      userId: 'user-diana',
      role: MemberRole.member,
      nickname: null,
      joinedAt: _mockBaseDate.subtract(const Duration(days: 45)),
      updatedAt: _mockBaseDate,
      name: 'Diana',
      avatarUrl: null,
      status: AvailabilityStatus.free,
      statusMessage: 'Coffee break',
    ),
    CircleMember(
      id: 'member-9',
      circleId: 'circle-2',
      userId: 'current-user',
      role: MemberRole.member,
      nickname: null,
      joinedAt: _mockBaseDate.subtract(const Duration(days: 58)),
      updatedAt: _mockBaseDate,
      name: 'You',
      avatarUrl: null,
      status: AvailabilityStatus.free,
      statusMessage: 'Working from home',
    ),
  ],
  'circle-3': [
    CircleMember(
      id: 'member-10',
      circleId: 'circle-3',
      userId: 'user-emma',
      role: MemberRole.member,
      nickname: null,
      joinedAt: _mockBaseDate.subtract(const Duration(days: 28)),
      updatedAt: _mockBaseDate,
      name: 'Emma',
      avatarUrl: null,
      status: AvailabilityStatus.doNotDisturb,
      statusMessage: 'Focus time',
    ),
    CircleMember(
      id: 'member-11',
      circleId: 'circle-3',
      userId: 'user-frank',
      role: MemberRole.member,
      nickname: null,
      joinedAt: _mockBaseDate.subtract(const Duration(days: 25)),
      updatedAt: _mockBaseDate,
      name: 'Frank',
      avatarUrl: null,
      status: AvailabilityStatus.offline,
      statusMessage: null,
      lastSeen: _mockBaseDate.subtract(const Duration(hours: 2)),
    ),
    CircleMember(
      id: 'member-12',
      circleId: 'circle-3',
      userId: 'current-user',
      role: MemberRole.admin,
      nickname: null,
      joinedAt: _mockBaseDate.subtract(const Duration(days: 30)),
      updatedAt: _mockBaseDate,
      name: 'You',
      avatarUrl: null,
      status: AvailabilityStatus.free,
      statusMessage: 'Working from home',
    ),
  ],
};
