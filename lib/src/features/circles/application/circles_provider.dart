import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/circle.dart';
import '../domain/circle_member.dart';
import '../../availability/domain/availability_status.dart';

/// Mock circles data provider
final circlesProvider = Provider<List<Circle>>((ref) {
  return _mockCircles;
});

/// Provider to get a specific circle by ID
final circleByIdProvider = Provider.family<Circle?, String>((ref, circleId) {
  final circles = ref.watch(circlesProvider);
  try {
    return circles.firstWhere((c) => c.id == circleId);
  } catch (_) {
    return null;
  }
});

/// Provider to get members of a specific circle
final circleMembersProvider = Provider.family<List<CircleMember>, String>((
  ref,
  circleId,
) {
  return _mockMembersByCircle[circleId] ?? [];
});

/// Provider to count free members in a circle
final circleFreeCountProvider = Provider.family<int, String>((ref, circleId) {
  final members = ref.watch(circleMembersProvider(circleId));
  return members.where((m) => m.status == AvailabilityStatus.free).length;
});

// ============================================================================
// Mock Data
// ============================================================================

final _mockCircles = [
  Circle(
    id: 'circle-1',
    name: 'Family',
    description: 'Stay connected with the fam',
    avatarUrl: null,
    createdBy: 'current-user',
    myRole: MemberRole.admin,
    memberCount: 4,
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
    updatedAt: DateTime.now(),
  ),
  Circle(
    id: 'circle-2',
    name: 'Close Friends',
    description: 'The inner circle',
    avatarUrl: null,
    createdBy: 'user-alice',
    myRole: MemberRole.member,
    memberCount: 5,
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now(),
  ),
  Circle(
    id: 'circle-3',
    name: 'Work Buddies',
    description: 'Colleagues who became friends',
    avatarUrl: null,
    createdBy: 'current-user',
    myRole: MemberRole.admin,
    memberCount: 3,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
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
      joinedAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
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
      joinedAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
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
      joinedAt: DateTime.now().subtract(const Duration(days: 85)),
      updatedAt: DateTime.now(),
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
      joinedAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
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
      joinedAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
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
      joinedAt: DateTime.now().subtract(const Duration(days: 55)),
      updatedAt: DateTime.now(),
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
      joinedAt: DateTime.now().subtract(const Duration(days: 50)),
      updatedAt: DateTime.now(),
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
      joinedAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now(),
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
      joinedAt: DateTime.now().subtract(const Duration(days: 58)),
      updatedAt: DateTime.now(),
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
      joinedAt: DateTime.now().subtract(const Duration(days: 28)),
      updatedAt: DateTime.now(),
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
      joinedAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
      name: 'Frank',
      avatarUrl: null,
      status: AvailabilityStatus.offline,
      statusMessage: null,
      lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    CircleMember(
      id: 'member-12',
      circleId: 'circle-3',
      userId: 'current-user',
      role: MemberRole.admin,
      nickname: null,
      joinedAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      name: 'You',
      avatarUrl: null,
      status: AvailabilityStatus.free,
      statusMessage: 'Working from home',
    ),
  ],
};
